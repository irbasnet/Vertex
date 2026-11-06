Add-Type -AssemblyName System.Drawing

function Recolor-And-Trim {
    param(
        [string]$SrcPath,
        [string]$DstPath,
        [byte]$R, [byte]$G, [byte]$B,
        [int]$AlphaFloor = 18,
        [int]$CropXStart = -1,
        [int]$CropXEnd = -1
    )

    $src = [System.Drawing.Bitmap]::FromFile($SrcPath)
    $w = $src.Width
    $h = $src.Height

    $rect = New-Object System.Drawing.Rectangle 0,0,$w,$h
    $bmpData = $src.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = [byte[]]::new([Math]::Abs($bmpData.Stride) * $h)
    [System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $bytes, 0, $bytes.Length)
    $stride = $bmpData.Stride

    for ($y = 0; $y -lt $h; $y++) {
        $rowOffset = $y * $stride
        for ($x = 0; $x -lt $w; $x++) {
            $idx = $rowOffset + $x * 4
            $a = $bytes[$idx + 3]
            if ($a -lt $AlphaFloor) {
                $bytes[$idx] = 0; $bytes[$idx+1] = 0; $bytes[$idx+2] = 0; $bytes[$idx+3] = 0
            } else {
                $bytes[$idx]   = $B
                $bytes[$idx+1] = $G
                $bytes[$idx+2] = $R
            }
        }
    }

    [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $bmpData.Scan0, $bytes.Length)
    $src.UnlockBits($bmpData)

    # compute content bbox
    $minX = $w; $maxX = -1; $minY = $h; $maxY = -1
    $rect2 = New-Object System.Drawing.Rectangle 0,0,$w,$h
    $bmpData2 = $src.LockBits($rect2, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes2 = [byte[]]::new([Math]::Abs($bmpData2.Stride) * $h)
    [System.Runtime.InteropServices.Marshal]::Copy($bmpData2.Scan0, $bytes2, 0, $bytes2.Length)
    $stride2 = $bmpData2.Stride
    $xs = $CropXStart; $xe = $CropXEnd
    if ($xs -lt 0) { $xs = 0 }
    if ($xe -lt 0) { $xe = $w - 1 }
    for ($y = 0; $y -lt $h; $y++) {
        $rowOffset = $y * $stride2
        for ($x = $xs; $x -le $xe; $x++) {
            $idx = $rowOffset + $x * 4
            $a = $bytes2[$idx + 3]
            if ($a -gt 0) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $src.UnlockBits($bmpData2)

    $pad = 6
    $cx = [Math]::Max($xs, $minX - $pad)
    $cy = [Math]::Max(0, $minY - $pad)
    $cw = [Math]::Min($xe, $maxX + $pad) - $cx + 1
    $ch = [Math]::Min($h - 1, $maxY + $pad) - $cy + 1

    $cropRect = New-Object System.Drawing.Rectangle $cx, $cy, $cw, $ch
    $cropped = New-Object System.Drawing.Bitmap($cw, $ch)
    $gfx = [System.Drawing.Graphics]::FromImage($cropped)
    $gfx.DrawImage($src, (New-Object System.Drawing.Rectangle 0,0,$cw,$ch), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
    $gfx.Dispose()

    $cropped.Save($DstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $cropped.Dispose()
    $src.Dispose()

    Write-Output "$DstPath -> bbox x:[$minX,$maxX] y:[$minY,$maxY] size ${cw}x${ch}"
}

# Full logo, recolored solid champagne gold, trimmed to content
Recolor-And-Trim -SrcPath "D:\vertex\Logo.png" -DstPath "D:\vertex\assets\img\logo-gold.png" -R 232 -G 184 -B 117 -AlphaFloor 18

# Full logo, recolored forest charcoal (for light backgrounds), trimmed
Recolor-And-Trim -SrcPath "D:\vertex\Logo.png" -DstPath "D:\vertex\assets\img\logo-charcoal.png" -R 22 -G 38 -B 34 -AlphaFloor 18

# Mark only (the V shape), gold - for favicon / compact header
Recolor-And-Trim -SrcPath "D:\vertex\Logo.png" -DstPath "D:\vertex\assets\img\mark-gold.png" -R 232 -G 184 -B 117 -AlphaFloor 18 -CropXStart 0 -CropXEnd 615

# Mark only, charcoal
Recolor-And-Trim -SrcPath "D:\vertex\Logo.png" -DstPath "D:\vertex\assets\img\mark-charcoal.png" -R 22 -G 38 -B 34 -AlphaFloor 18 -CropXStart 0 -CropXEnd 615
