param(
    [Parameter(Mandatory = $true)]
    [string]$Directory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# Keep source ASCII-only so Windows PowerShell 5.1 can parse it without a UTF-8 BOM.
$suffixes = @{
    vertical  = -join ([char[]](31446, 29256))
    video     = -join ([char[]](35270, 39057, 21495))
    bilibili  = 'bilibili'
    horizontal = -join ([char[]](27178, 29256))
    article   = -join ([char[]](20844, 20247, 21495))
    base      = -join ([char[]](24213, 22270))
}

$expected = @{
    vertical   = @(1242, 1660)
    video      = @(1080, 1260)
    bilibili   = @(1600, 1000)
    horizontal = @(1920, 1080)
    article    = @(900, 383)
    base       = @(1080, 1260)
}

$results = foreach ($variant in $expected.Keys) {
    $suffix = $suffixes[$variant]
    $file = Get-ChildItem -LiteralPath $Directory -Filter "*-$suffix.png" | Select-Object -First 1
    if (-not $file) {
        [pscustomobject]@{ Variant=$variant; File='MISSING'; Dimensions='FAIL'; SpecialPixels='FAIL'; Details='Expected PNG not found' }
        continue
    }

    $bitmap = [System.Drawing.Bitmap]::new($file.FullName)
    try {
        $size = $expected[$variant]
        $dimensionPass = ($bitmap.Width -eq $size[0] -and $bitmap.Height -eq $size[1])
        $specialPass = $true
        $details = @()

        if ($variant -eq 'video' -and $dimensionPass) {
            $bad = 0L
            for ($y = 0; $y -lt 1260; $y++) {
                foreach ($x in (0..59 + 1020..1079)) {
                    $c = $bitmap.GetPixel($x, $y)
                    if (-not ($c.A -eq 255 -and $c.R -eq 255 -and $c.G -eq 255 -and $c.B -eq 255)) { $bad++ }
                }
            }
            $specialPass = ($bad -eq 0)
            $details += "white-margin violations=$bad"
        }

        if ($variant -eq 'base' -and $dimensionPass) {
            $bad = 0L
            for ($y = 422; $y -lt 1260; $y++) {
                for ($x = 0; $x -lt 1080; $x++) {
                    $c = $bitmap.GetPixel($x, $y)
                    if (-not ($c.A -eq 255 -and $c.R -eq 0 -and $c.G -eq 0 -and $c.B -eq 0)) { $bad++ }
                }
            }
            $specialPass = ($bad -eq 0)
            $details += "black-reserve violations=$bad"
        }

        [pscustomobject]@{
            Variant = $variant
            File = $file.Name
            Dimensions = if ($dimensionPass) { 'PASS' } else { "FAIL ($($bitmap.Width)x$($bitmap.Height))" }
            SpecialPixels = if ($specialPass) { 'PASS' } else { 'FAIL' }
            Details = $details -join '; '
        }
    }
    finally {
        $bitmap.Dispose()
    }
}

$results | Sort-Object Variant | Format-Table -AutoSize
if ($results.Dimensions -match '^FAIL' -or $results.SpecialPixels -contains 'FAIL') { exit 1 }
