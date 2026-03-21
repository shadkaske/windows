param(
    [switch]$DebugOutput
)

$configRoot = Join-Path $PSScriptRoot 'configs'
$configRoot = Join-Path $PSScriptRoot 'configs'

if (-not (Test-Path $configRoot -PathType Container)) {
    throw "Config Directory Not Found: $configRoot"
}

# Initialize leaf directory mapping
$leafDirectories = @{}

Get-ChildItem -Path $configRoot -Directory -Recurse | ForEach-Object {
    $childDirs = Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue
    if ($childDirs.Count -eq 0) {
        $relative = $null
        if ($_.FullName -eq $configRoot) {
            $relative = '.'
        } else {
            $relative = $_.FullName.Substring($configRoot.Length + 1)
        }
        $leafDirectories[$relative] = $_.FullName
    }
}

# Optional: also includes the root's own leaf behavior if root has no child directories
# (Usually not needed since configs has children.)
if ((Get-ChildItem -Path $configRoot -Directory).Count -eq 0) {
    $leafDirectories['.'] = $configRoot
}

# Convert to associative array variable name for clarity
$leafArray = $leafDirectories

function Get-JunctionTarget {
    param([string]$Path)

    if (-not (Test-Path -Path $Path -PathType Container -ErrorAction SilentlyContinue)) {
        return $null
    }

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item -or -not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        return $null
    }

    try {
        return $item.Target
    } catch {
        return $null
    }
}

function Ensure-UniqueBackupPath {
    param([string]$Path)

    $backup = $Path + '_old'
    $i = 1
    while (Test-Path $backup) {
        $backup = "${Path}_old_$i"
        $i++
    }
    return $backup
}

foreach ($entry in $leafArray.GetEnumerator()) {
    $relative = $entry.Key
    $source = $entry.Value
    $destination = Join-Path $env:USERPROFILE $relative

    if ($DebugOutput) {
        Write-Host "[DEBUG] Relative: $relative"
        Write-Host "[DEBUG] Source: $source"
        Write-Host "[DEBUG] Destination: $destination"
        if (Test-Path $destination) {
            Write-Host "[DEBUG] Destination exists: $destination"
        } else {
            Write-Host "[DEBUG] Destination does not exist: $destination"
        }
    }

    # Create parent folders in profile if needed
    $destDir = Split-Path -Path $destination -Parent
    if (-not (Test-Path $destDir)) {
        if ($DebugOutput) { Write-Host "[DEBUG] Creating parent directory: $destDir" }
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $existingTarget = Get-JunctionTarget -Path $destination

    if ($existingTarget) {
        # Normalize both paths for comparison
        $resolvedExisting = (Resolve-Path -LiteralPath $existingTarget -ErrorAction SilentlyContinue).ProviderPath
        $resolvedSource = (Resolve-Path -LiteralPath $source -ErrorAction SilentlyContinue).ProviderPath

        if ($DebugOutput) {
            Write-Host "[DEBUG] Existing junction target: $existingTarget"
            Write-Host "[DEBUG] Resolved existing: $resolvedExisting"
            Write-Host "[DEBUG] Resolved source: $resolvedSource"
        }

        if ($resolvedExisting -and $resolvedSource -and $resolvedExisting -eq $resolvedSource) {
            Write-Host "OK: Junction already exists: $destination -> $resolvedExisting"
            continue
        }

        Write-Host "Replacing junction at $destination (currently points to $resolvedExisting)"
        Remove-Item -LiteralPath $destination -Force
    } elseif (Test-Path -LiteralPath $destination) {
        Write-Host "Existing non-junction path found at $destination. Moving to backup."
        $backup = Ensure-UniqueBackupPath -Path $destination
        Move-Item -LiteralPath $destination -Destination $backup -Force
        Write-Host "Moved $destination -> $backup"
    }

    # Create junction from destination to source
    Write-Host "Creating junction: $destination -> $source"
    New-Item -ItemType Junction -Path $destination -Target $source -Force | Out-Null
}

# Output summary for debugging
Write-Host "Done. Processed $($leafArray.Count) leaf entries."