# ============================================================
# TRADECOVEX - FRESHNESS UPDATE
# Updates schema dateModified to 2026-04-23 on all HTML pages
# Leaves datePublished untouched (keeps original publish dates)
# ============================================================

cd D:\Tradecovex\website

$newDate = "2026-04-23T00:00:00+00:00"
$count = 0
$skipped = 0

Get-ChildItem -Path "guides\*.html","compare\*.html","*.html" -File | ForEach-Object {
    $file = $_.FullName
    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
    $original = $content

    # Match both spaced and unspaced JSON-LD dateModified formats
    $content = [regex]::Replace($content, '"dateModified"\s*:\s*"[^"]+"', '"dateModified": "' + $newDate + '"')

    if ($content -ne $original) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file, $content, $utf8NoBom)
        Write-Host "  OK: $($_.Name)" -ForegroundColor Green
        $count++
    } else {
        Write-Host "  SKIP (no dateModified): $($_.Name)" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "Updated: $count files" -ForegroundColor Green
Write-Host "Skipped: $skipped files" -ForegroundColor Yellow
