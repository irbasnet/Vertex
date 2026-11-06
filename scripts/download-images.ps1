$ErrorActionPreference = "Stop"
$outDir = "D:\vertex\assets\img"

$images = @(
    @{ name = "hero.jpg";                  id = "photo-1774516534068-77422d9226e6"; w = 2400 },
    @{ name = "service-plain.jpg";          id = "photo-1772300704502-410f0fbd43bb"; w = 1800 },
    @{ name = "service-plain-2.jpg";        id = "photo-1772305336606-989a457ffbae"; w = 1800 },
    @{ name = "service-metallic.jpg";       id = "photo-1585749865060-6c04f2481d62"; w = 1800 },
    @{ name = "service-textured.jpg";       id = "photo-1633319987325-aae32f3d8dd3"; w = 1800 },
    @{ name = "service-textured-2.jpg";     id = "photo-1750056661722-8381f9012079"; w = 1800 },
    @{ name = "service-pathways.jpg";       id = "photo-1761637822930-fb1c1a3df94d"; w = 1800 },
    @{ name = "service-pathways-2.jpg";     id = "photo-1759224005115-cc3c38202a9d"; w = 1800 },
    @{ name = "about.jpg";                  id = "photo-1754494977459-f5bf1acf0689"; w = 1800 },
    @{ name = "pathway-detail.jpg";         id = "photo-1763909129689-0ef3655fc03c"; w = 1800 }
)

foreach ($img in $images) {
    $url = "https://images.unsplash.com/$($img.id)?fm=jpg&q=80&w=$($img.w)&auto=format&fit=crop&ixlib=rb-4.1.0"
    $dest = Join-Path $outDir $img.name
    Write-Output "Downloading $($img.name) ..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UserAgent "Mozilla/5.0"
    $size = (Get-Item $dest).Length
    Write-Output "  -> $dest ($size bytes)"
}
