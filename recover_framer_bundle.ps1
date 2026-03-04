param(
    [string]$HtmlPath = "./City5.html",
    [string]$AssetsDir = "./City5_files",
    [switch]$RewriteHtml = $true,
    [switch]$DownloadSourceMaps = $true
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $HtmlPath)) {
    throw "HTML file not found: $HtmlPath"
}

if (-not (Test-Path $AssetsDir)) {
    New-Item -ItemType Directory -Path $AssetsDir | Out-Null
}

$htmlFullPath = (Resolve-Path $HtmlPath).Path
$assetsFullPath = (Resolve-Path $AssetsDir).Path

$content = Get-Content -Raw -Path $htmlFullPath

$regex = 'https://framerusercontent\.com/sites/[^"''\s>]+?\.mjs(?:\?[^"''\s>]*)?'
$matches = [regex]::Matches($content, $regex)

$urls = @()
foreach ($m in $matches) {
    $urls += $m.Value
}

$urls = $urls | Sort-Object -Unique

if (-not $urls -or $urls.Count -eq 0) {
    throw "No Framer .mjs URLs found in $HtmlPath"
}

Write-Host "Found $($urls.Count) module URLs"

$downloaded = @()
$failed = @()

foreach ($url in $urls) {
    try {
        $uri = [System.Uri]$url
        $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
        $targetPath = Join-Path $assetsFullPath $fileName

        Invoke-WebRequest -Uri $url -OutFile $targetPath -UseBasicParsing
        $downloaded += [PSCustomObject]@{ Url = $url; FileName = $fileName; Path = $targetPath }
        Write-Host "Downloaded: $fileName"

        if ($DownloadSourceMaps) {
            $mapUrl = "$url.map"
            $mapFileName = "$fileName.map"
            $mapTargetPath = Join-Path $assetsFullPath $mapFileName
            try {
                Invoke-WebRequest -Uri $mapUrl -OutFile $mapTargetPath -UseBasicParsing
                Write-Host "Downloaded map: $mapFileName"
            }
            catch {
                Write-Host "Map missing: $mapFileName"
            }
        }
    }
    catch {
        $failed += [PSCustomObject]@{ Url = $url; Error = $_.Exception.Message }
        Write-Warning "Failed: $url"
    }
}

if ($RewriteHtml) {
    $newContent = $content

    foreach ($entry in $downloaded) {
        $escaped = [regex]::Escape($entry.Url)
        $replacement = "./City5_files/$($entry.FileName)"
        $newContent = [regex]::Replace($newContent, $escaped, $replacement)
    }

    $backupPath = "$htmlFullPath.bak"
    Copy-Item -Path $htmlFullPath -Destination $backupPath -Force
    Set-Content -Path $htmlFullPath -Value $newContent -Encoding UTF8

    Write-Host "Updated HTML with local module paths"
    Write-Host "Backup saved to: $backupPath"
}

$reportPath = Join-Path (Split-Path -Parent $htmlFullPath) "framer_recovery_report.txt"
$report = @()
$report += "Framer Recovery Report"
$report += "Generated: $(Get-Date -Format o)"
$report += ""
$report += "Downloaded: $($downloaded.Count)"
$report += "Failed: $($failed.Count)"
$report += ""
$report += "Downloaded files:"
$report += ($downloaded | ForEach-Object { "- $($_.FileName)" })

if ($failed.Count -gt 0) {
    $report += ""
    $report += "Failures:"
    $report += ($failed | ForEach-Object { "- $($_.Url)`n  $($_.Error)" })
}

Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host "Report written: $reportPath"

if ($failed.Count -gt 0) {
    Write-Warning "Some downloads failed. Check framer_recovery_report.txt"
}

Write-Host "Done."
