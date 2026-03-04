# === Update all placeholder links in City5.html and MJS files ===

$base = "c:\Users\VICTUS\Desktop\ffh"

# --- 1. City5.html ---
$htmlPath = Join-Path $base "City5.html"
$html = [System.IO.File]::ReadAllText($htmlPath)

# 1a. WhatsApp link
$html = $html.Replace('href="https://wa.me/91XXXXXXXXXX"', 'href="https://wa.me/918276893906"')

# 1b. Instagram CTA (Section 3) - careful to only match the Section 3 button
$html = $html.Replace('data-framer-name="Section 3" style="width: 100%; opacity: 1;" href="#" rel="noopener"', 'data-framer-name="Section 3" style="width: 100%; opacity: 1;" href="https://www.instagram.com/fickle_stick_" target="_blank" rel="noopener"')

# 1c. Main "See the route" CTA button (Section 1)
$html = $html.Replace('data-framer-name="Section 1" style="width: 100%; opacity: 1;" href="#location" rel="noopener"', 'data-framer-name="Section 1" style="width: 100%; opacity: 1;" href="https://maps.app.goo.gl/6zjTh7n1hKZfZ3Ps8" target="_blank" rel="noopener"')

# 1d. Event card "See the route" links - add href based on venue context
# Strategy: Find each "See the route" anchor tag and replace with the appropriate map link
# The cards appear in order: DADHI MANGAL, GAYE HOLUD, BIYE, Bodhu Boron, BOU BHAAT, Reception

$groomHouse = "https://maps.app.goo.gl/s25Fpf26QJ92VvmNA"
$weddingVenue = "https://maps.app.goo.gl/6zjTh7n1hKZfZ3Ps8"
$receptionVenue = "https://maps.app.goo.gl/rW7WcWtgG5ba2mfYA"

# All 6 event card "See the route" links are identical anchor tags without href
$oldLink = '<a class="framer-text framer-styles-preset-s3v1ib" data-styles-preset="LLOdYO6e3">See the route</a>'

# We need to replace them in order. The cards appear sequentially in HTML.
# Card 1: DADHI MANGAL - Groom's house
# Card 2: GAYE HOLUD - Groom's house  
# Card 3: BIYE - Wedding venue
# Card 4: Bodhu Boron - Groom's house
# Card 5: BOU BHAAT - Groom's house
# Card 6: Reception - Reception venue

$mapUrls = @($groomHouse, $groomHouse, $weddingVenue, $groomHouse, $groomHouse, $receptionVenue)

# Replace each occurrence sequentially
for ($i = 0; $i -lt 6; $i++) {
    $url = $mapUrls[$i]
    $newLink = '<a class="framer-text framer-styles-preset-s3v1ib" data-styles-preset="LLOdYO6e3" href="' + $url + '" target="_blank">See the route</a>'
    
    # Find the first occurrence and replace only that one
    $idx = $html.IndexOf($oldLink)
    if ($idx -ge 0) {
        $html = $html.Substring(0, $idx) + $newLink + $html.Substring($idx + $oldLink.Length)
        Write-Host "  Card $($i+1): Added href=$url"
    } else {
        Write-Host "  Card $($i+1): WARNING - link not found!"
    }
}

[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Host "City5.html updated successfully."

# --- 2. MJS files - WhatsApp links ---
$mjsFiles = Get-ChildItem -Path (Join-Path $base "City5_files") -Filter "*.mjs" -File
$waOld = 'https://wa.me/91XXXXXXXXXX'
$waNew = 'https://wa.me/918276893906'
$waCount = 0

foreach ($f in $mjsFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    if ($content.Contains($waOld)) {
        $content = $content.Replace($waOld, $waNew)
        [System.IO.File]::WriteAllText($f.FullName, $content)
        $waCount++
        Write-Host "  WhatsApp updated in: $($f.Name)"
    }
}
Write-Host "WhatsApp links updated in $waCount MJS files."

# --- 3. MJS files - Instagram CTA link (i9HrUZDnv:`#`) ---
# The Instagram CTA button uses prop i9HrUZDnv:`#` in MJS files
$igOld = "i9HrUZDnv:``#``"
$igNew = "i9HrUZDnv:``https://www.instagram.com/fickle_stick_``"
$igCount = 0

foreach ($f in $mjsFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    if ($content.Contains($igOld)) {
        $content = $content.Replace($igOld, $igNew)
        [System.IO.File]::WriteAllText($f.FullName, $content)
        $igCount++
        Write-Host "  Instagram CTA updated in: $($f.Name)"
    }
}
Write-Host "Instagram CTA links updated in $igCount MJS files."

# --- 4. MJS .map files - WhatsApp and Instagram ---
$mapFiles = Get-ChildItem -Path (Join-Path $base "City5_files") -Filter "*.mjs.map" -File
foreach ($f in $mapFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    $changed = $false
    if ($content.Contains($waOld)) {
        $content = $content.Replace($waOld, $waNew)
        $changed = $true
    }
    # In .map files, the Instagram prop uses escaped quotes
    $igOldMap = 'i9HrUZDnv:\"#\"'
    $igNewMap = 'i9HrUZDnv:\"https://www.instagram.com/fickle_stick_\"'
    if ($content.Contains($igOldMap)) {
        $content = $content.Replace($igOldMap, $igNewMap)
        $changed = $true
    }
    if ($changed) {
        [System.IO.File]::WriteAllText($f.FullName, $content)
        Write-Host "  Map file updated: $($f.Name)"
    }
}

Write-Host "`nAll link updates complete!"
