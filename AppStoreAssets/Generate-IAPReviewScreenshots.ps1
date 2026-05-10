Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $root "IAPReviewScreenshots-1242x2208"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$width = 1290
$height = 2796
$targetWidth = 1242
$targetHeight = 2208

function Color-Hex($hex) {
    $clean = $hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($clean.Substring(0, 2), 16),
        [Convert]::ToInt32($clean.Substring(2, 2), 16),
        [Convert]::ToInt32($clean.Substring(4, 2), 16)
    )
}

function Brush-Hex($hex) {
    return New-Object System.Drawing.SolidBrush (Color-Hex $hex)
}

function Font-New($size, $style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function RectF($x, $y, $w, $h) {
    return New-Object System.Drawing.RectangleF([float]$x, [float]$y, [float]$w, [float]$h)
}

function Path-RoundedRect($rect, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = [float]($radius * 2)
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-RoundedRect($graphics, $brush, $rect, $radius) {
    $path = Path-RoundedRect $rect $radius
    $graphics.FillPath($brush, $path)
    $path.Dispose()
}

function Stroke-RoundedRect($graphics, $pen, $rect, $radius) {
    $path = Path-RoundedRect $rect $radius
    $graphics.DrawPath($pen, $path)
    $path.Dispose()
}

function Draw-Text($graphics, $text, $font, $brush, $x, $y, $w, $h, $align = "Near") {
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::$align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $graphics.DrawString($text, $font, $brush, (RectF $x $y $w $h), $format)
    $format.Dispose()
}

function Draw-Progress($graphics, $x, $y, $w, $h, $percent) {
    Fill-RoundedRect $graphics (Brush-Hex "#121A29") (RectF $x $y $w $h) 16
    Fill-RoundedRect $graphics (Brush-Hex "#FFD343") (RectF $x $y ($w * $percent) $h) 16
}

function Draw-Pill($graphics, $x, $y, $w, $text, $accent = "#19B7FF") {
    Fill-RoundedRect $graphics (Brush-Hex "#101C2D") (RectF $x $y $w 58) 22
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex $accent), 2)) (RectF $x $y $w 58) 22
    Draw-Text $graphics $text (Font-New 24 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#D8F4FF") $x ($y + 13) $w 36 "Center"
}

function Draw-SmallProduct($graphics, $x, $y, $w, $title, $meta) {
    Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF $x $y $w 134) 28
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#263955"), 2)) (RectF $x $y $w 134) 28
    Fill-RoundedRect $graphics (Brush-Hex "#19B7FF") (RectF ($x + 26) ($y + 26) 70 70) 20
    Draw-Text $graphics "V" (Font-New 41 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#07101D") ($x + 26) ($y + 32) 70 55 "Center"
    Draw-Text $graphics $title (Font-New 29 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F5FAFF") ($x + 118) ($y + 28) ($w - 150) 42
    Draw-Text $graphics $meta (Font-New 23) (Brush-Hex "#79E7FF") ($x + 118) ($y + 78) ($w - 150) 34
}

function Draw-Screenshot($product) {
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0, 0, $width, $height)),
        (Color-Hex "#050914"),
        (Color-Hex "#101A2E"),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $graphics.FillRectangle($bgBrush, 0, 0, $width, $height)

    for ($i = 0; $i -lt 11; $i++) {
        $pen = New-Object System.Drawing.Pen((Color-Hex "#10243A"), 2)
        $graphics.DrawLine($pen, 0, 220 + ($i * 210), $width, 80 + ($i * 210))
        $pen.Dispose()
    }

    Draw-Text $graphics "9:41" (Font-New 28 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F4FAFF") 78 42 150 45
    Fill-RoundedRect $graphics (Brush-Hex "#F4FAFF") (RectF 1065 56 70 24) 8
    Fill-RoundedRect $graphics (Brush-Hex "#F4FAFF") (RectF 1154 56 42 24) 8

    Fill-RoundedRect $graphics (Brush-Hex "#07111F") (RectF 54 118 1182 2520) 50
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#1D344E"), 3)) (RectF 54 118 1182 2520) 50

    Draw-Text $graphics "VoltRush AI" (Font-New 50 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F6FAFF") 110 178 560 70
    Draw-Text $graphics "Shop" (Font-New 35 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 1060 188 120 50 "Center"
    Draw-Text $graphics "Electrician learning simulator" (Font-New 30) (Brush-Hex "#AFC1D6") 112 246 700 48

    Fill-RoundedRect $graphics (Brush-Hex "#0C1727") (RectF 110 330 1070 280) 34
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#1BCAFF"), 2)) (RectF 110 330 1070 280) 34
    Draw-Text $graphics "Upgrade your training simulator" (Font-New 42 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 152 370 820 60
    Draw-Text $graphics "Practice game-style electrician missions, fault diagnosis, wiring puzzles, quizzes, AI mentor explanations, and career progression." (Font-New 27) (Brush-Hex "#B6C9DE") 152 436 840 104
    Draw-Progress $graphics 152 558 560 22 0.68
    Draw-Text $graphics "Level 12  |  7 day streak" (Font-New 24) (Brush-Hex "#79E7FF") 750 544 360 40

    Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 110 690 1070 760) 42
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#19B7FF"), 4)) (RectF 110 690 1070 760) 42
    Fill-RoundedRect $graphics (Brush-Hex "#FFD343") (RectF 158 742 118 118) 28
    Draw-Text $graphics "V" (Font-New 74 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#07101D") 158 752 118 92 "Center"
    Draw-Pill $graphics 312 748 270 $product.Badge "#FFD343"
    Draw-Text $graphics $product.Title (Font-New 58 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 154 902 820 80
    Draw-Text $graphics $product.Subtitle (Font-New 32) (Brush-Hex "#C2D4E9") 154 994 885 100
    Draw-Text $graphics $product.Price (Font-New 38 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 154 1118 600 60

    $benefitY = 1194
    foreach ($benefit in $product.Benefits) {
        Fill-RoundedRect $graphics (Brush-Hex "#19B7FF") (RectF 158 $benefitY 28 28) 14
        Draw-Text $graphics $benefit (Font-New 28) (Brush-Hex "#E8F6FF") 208 ($benefitY - 8) 850 48
        $benefitY += 58
    }

    Fill-RoundedRect $graphics (Brush-Hex "#FFD343") (RectF 154 1360 880 84) 24
    Draw-Text $graphics $product.Button (Font-New 34 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#07101D") 154 1383 880 48 "Center"

    Draw-Text $graphics "Included in VoltRush AI" (Font-New 36 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F6FAFF") 112 1518 640 54
    Draw-SmallProduct $graphics 110 1590 510 "Career Mode" "Missions and XP"
    Draw-SmallProduct $graphics 670 1590 510 "Fault Battle" "Timed diagnosis"
    Draw-SmallProduct $graphics 110 1760 510 "Wiring Lab" "Interactive puzzles"
    Draw-SmallProduct $graphics 670 1760 510 "Quiz Arena" "Practice and timed"
    Draw-SmallProduct $graphics 110 1930 510 "AI Mentor" "Mock explanations"
    Draw-SmallProduct $graphics 670 1930 510 "Business Mode" "Contractor sim"

    Fill-RoundedRect $graphics (Brush-Hex "#111C2C") (RectF 110 2150 1070 286) 34
    Draw-Text $graphics "Learning and simulation only" (Font-New 34 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 154 2192 780 50
    Draw-Text $graphics "VoltRush AI does not replace formal electrician training, licensing, code compliance, local regulations, manufacturer instructions, inspections, or qualified professional guidance." (Font-New 26) (Brush-Hex "#BDD0E4") 154 2250 920 104
    Draw-Text $graphics "Purchases unlock educational simulator content only. They have no cash value and do not provide certification." (Font-New 24) (Brush-Hex "#79E7FF") 154 2360 920 58

    Draw-Pill $graphics 110 2520 1070 ("Product shown: " + $product.Title) "#19B7FF"

    $path = Join-Path $outDir $product.File
    $targetBitmap = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $targetGraphics = [System.Drawing.Graphics]::FromImage($targetBitmap)
    $targetGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $targetGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $targetGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $targetGraphics.Clear([System.Drawing.Color]::FromArgb(5, 9, 20))
    $targetGraphics.DrawImage($bitmap, 0, 0, $targetWidth, $targetHeight)
    $targetBitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $bgBrush.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
    $targetGraphics.Dispose()
    $targetBitmap.Dispose()
}

$products = @(
    @{
        Key = "monthly"; Title = "Monthly Premium"; File = "monthly_premium_review.png"; Badge = "Subscription";
        Subtitle = "Unlimited missions, advanced fault scenarios, AI Mentor, PvP battles, contractor mode, and detailed progress analytics.";
        Price = "Monthly access"; Button = "Start Monthly Premium";
        Benefits = @("Unlimited daily missions", "Advanced fault diagnosis scenarios", "AI Mentor and progress analytics")
    },
    @{
        Key = "yearly"; Title = "Yearly Premium"; File = "yearly_premium_review.png"; Badge = "Subscription";
        Subtitle = "Annual access to every premium learning mode, certification pack, tournament, and business simulator feature.";
        Price = "Yearly access"; Button = "Start Yearly Premium";
        Benefits = @("Best value premium access", "Certification packs included", "PvP tournaments and contractor tools")
    },
    @{
        Key = "uk"; Title = "UK Wiring Pack"; File = "uk_wiring_pack_review.png"; Badge = "One-time pack";
        Subtitle = "Unlock simulated UK wiring missions, regulation-style quizzes, and wiring challenges for the lab.";
        Price = "One-time purchase"; Button = "Unlock UK Wiring Pack";
        Benefits = @("UK Wiring learning path", "Lighting, socket, and ring final puzzles", "Regulation-style quizzes")
    },
    @{
        Key = "nec"; Title = "NEC Pack"; File = "nec_pack_review.png"; Badge = "One-time pack";
        Subtitle = "Unlock simulated NEC missions, code-style quizzes, and wiring challenges for US-focused study.";
        Price = "One-time purchase"; Button = "Unlock NEC Pack";
        Benefits = @("NEC learning path", "Panel, branch circuit, and fault missions", "Code-style quiz practice")
    },
    @{
        Key = "solar"; Title = "Solar & EV Pack"; File = "solar_ev_pack_review.png"; Badge = "One-time pack";
        Subtitle = "Unlock simulated solar inverter and EV charger missions with safety-focused wiring challenges.";
        Price = "One-time purchase"; Button = "Unlock Solar & EV Pack";
        Benefits = @("EV charger installation scenarios", "Solar inverter troubleshooting", "Safety checks and quiz practice")
    },
    @{
        Key = "coins"; Title = "Small Coin Pack"; File = "small_coin_pack_review.png"; Badge = "Consumable";
        Subtitle = "Add optional virtual coins for cosmetic progression items and game-style boosts inside the simulator.";
        Price = "Consumable coins"; Button = "Buy Small Coin Pack";
        Benefits = @("Optional virtual game coins", "Cosmetic and progression boosts", "No cash value or real-world reward")
    }
)

foreach ($product in $products) {
    Draw-Screenshot $product
}

Write-Host "Generated review screenshots:"
Get-ChildItem -Path $outDir -Filter "*.png" | ForEach-Object { Write-Host $_.FullName }
