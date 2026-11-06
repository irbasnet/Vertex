Add-Type -AssemblyName System.Drawing

function Resize-And-SaveJpeg {
    param(
        [string]$SrcPath,
        [string]$DstPath,
        [int]$MaxWidth = 2400,
        [int]$Quality = 82
    )

    $src = [System.Drawing.Image]::FromFile($SrcPath)
    $ratio = [Math]::Min(1.0, $MaxWidth / $src.Width)
    $w = [int]([Math]::Round($src.Width * $ratio))
    $h = [int]([Math]::Round($src.Height * $ratio))

    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $bmp.SetResolution($src.HorizontalResolution, $src.VerticalResolution)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gfx.DrawImage($src, 0, 0, $w, $h)
    $gfx.Dispose()
    $src.Dispose()

    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
    $bmp.Save($DstPath, $jpegCodec, $encParams)
    $bmp.Dispose()

    $size = (Get-Item $DstPath).Length
    Write-Output "$DstPath -> ${w}x${h}, $size bytes"
}

Resize-And-SaveJpeg -SrcPath "D:\vertex\Luxury SUV in a Marble-Lit Garage.png" -DstPath "D:\vertex\assets\img\hero-carousel-1.jpg"
Resize-And-SaveJpeg -SrcPath "D:\vertex\Luxury Marble Epoxy Man Cave.png" -DstPath "D:\vertex\assets\img\hero-carousel-2.jpg"
Resize-And-SaveJpeg -SrcPath "D:\vertex\Minimalist White Cabinet Garage.png" -DstPath "D:\vertex\assets\img\hero-carousel-3.jpg"
