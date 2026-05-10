Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $root "AppScreenshots-6.5in-1242x2688"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$width = 1242
$height = 2688

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

function Draw-Pill($graphics, $x, $y, $w, $text, $fill = "#101C2D", $stroke = "#19B7FF") {
    Fill-RoundedRect $graphics (Brush-Hex $fill) (RectF $x $y $w 60) 22
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex $stroke), 2)) (RectF $x $y $w 60) 22
    Draw-Text $graphics $text (Font-New 24 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#E9F8FF") $x ($y + 14) $w 36 "Center"
}

function Draw-Base($graphics, $title, $subtitle) {
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0, 0, $width, $height)),
        (Color-Hex "#050914"),
        (Color-Hex "#101B2E"),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $graphics.FillRectangle($bgBrush, 0, 0, $width, $height)
    $bgBrush.Dispose()

    for ($i = 0; $i -lt 12; $i++) {
        $pen = New-Object System.Drawing.Pen((Color-Hex "#10243A"), 2)
        $graphics.DrawLine($pen, 0, 250 + ($i * 220), $width, 90 + ($i * 220))
        $pen.Dispose()
    }

    Draw-Text $graphics "VoltRush AI" (Font-New 52 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F6FAFF") 86 74 540 70
    Draw-Text $graphics "9:41" (Font-New 28 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F6FAFF") 82 28 140 38
    Fill-RoundedRect $graphics (Brush-Hex "#EDF7FF") (RectF 1030 42 68 24) 8
    Fill-RoundedRect $graphics (Brush-Hex "#EDF7FF") (RectF 1120 42 42 24) 8

    Draw-Text $graphics $title (Font-New 64 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 86 178 1030 160
    Draw-Text $graphics $subtitle (Font-New 31) (Brush-Hex "#BDD3E9") 88 334 980 100
}

function Draw-PhoneFrame($graphics, $x, $y, $w, $h) {
    Fill-RoundedRect $graphics (Brush-Hex "#07111F") (RectF $x $y $w $h) 54
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#1D344E"), 4)) (RectF $x $y $w $h) 54
}

function Draw-Stat($graphics, $x, $y, $w, $label, $value, $accent = "#19B7FF") {
    Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF $x $y $w 150) 28
    Draw-Text $graphics $label (Font-New 23) (Brush-Hex "#9FB3C8") ($x + 28) ($y + 26) ($w - 56) 34
    Draw-Text $graphics $value (Font-New 40 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex $accent) ($x + 28) ($y + 72) ($w - 56) 54
}

function Draw-ButtonCard($graphics, $x, $y, $w, $title, $subtitle, $accent = "#19B7FF") {
    Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF $x $y $w 154) 28
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#263955"), 2)) (RectF $x $y $w 154) 28
    Fill-RoundedRect $graphics (Brush-Hex $accent) (RectF ($x + 26) ($y + 32) 70 70) 20
    Draw-Text $graphics "V" (Font-New 41 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#07101D") ($x + 26) ($y + 38) 70 55 "Center"
    Draw-Text $graphics $title (Font-New 30 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F5FAFF") ($x + 118) ($y + 32) ($w - 150) 44
    Draw-Text $graphics $subtitle (Font-New 23) (Brush-Hex "#79E7FF") ($x + 118) ($y + 82) ($w - 150) 34
}

function Draw-MissionCard($graphics, $x, $y, $w, $title, $meta, $reward, $risk) {
    Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF $x $y $w 198) 30
    Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#263955"), 2)) (RectF $x $y $w 198) 30
    Draw-Text $graphics $title (Font-New 33 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F7FBFF") ($x + 34) ($y + 28) ($w - 68) 46
    Draw-Text $graphics $meta (Font-New 23) (Brush-Hex "#BDD3E9") ($x + 34) ($y + 80) ($w - 68) 36
    Draw-Pill $graphics ($x + 34) ($y + 126) 190 $reward "#13273C" "#FFD343"
    Draw-Pill $graphics ($x + 248) ($y + 126) 180 $risk "#13273C" "#19B7FF"
}

function Draw-Screenshot($fileName, $title, $subtitle, $scene) {
    $bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    Draw-Base $graphics $title $subtitle
    Draw-PhoneFrame $graphics 66 488 1110 2056

    switch ($scene) {
        "dashboard" {
            Draw-Text $graphics "Dashboard" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 520 60
            Draw-Pill $graphics 855 552 240 "7 day streak" "#101C2D" "#FFD343"
            Draw-Stat $graphics 122 650 310 "Level" "12" "#FFD343"
            Draw-Stat $graphics 466 650 310 "XP" "8,450" "#19B7FF"
            Draw-Stat $graphics 810 650 310 "Coins" "1,240" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 850 998 280) 34
            Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#19B7FF"), 3)) (RectF 122 850 998 280) 34
            Draw-Text $graphics "Daily Mission" (Font-New 34 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 168 900 420 52
            Draw-Text $graphics "Diagnose a tripping breaker without unsafe tool choices." (Font-New 29) (Brush-Hex "#D6E8F8") 168 966 780 78
            Draw-Pill $graphics 168 1062 220 "+320 XP" "#07111F" "#19B7FF"
            Draw-Pill $graphics 420 1062 220 "+85 coins" "#07111F" "#FFD343"
            Draw-ButtonCard $graphics 122 1228 474 "Career Mode" "Unlock ranks" "#19B7FF"
            Draw-ButtonCard $graphics 646 1228 474 "Fault Battle" "Race the AI" "#FFD343"
            Draw-ButtonCard $graphics 122 1416 474 "Wiring Lab" "Puzzle circuits" "#19B7FF"
            Draw-ButtonCard $graphics 646 1416 474 "Quiz Arena" "Timed tests" "#FFD343"
            Draw-ButtonCard $graphics 122 1604 474 "AI Mentor" "Explain answers" "#19B7FF"
            Draw-ButtonCard $graphics 646 1604 474 "Shop" "Premium packs" "#FFD343"
            Draw-Text $graphics "Learning and simulation only. Follow local regulations and qualified professional guidance." (Font-New 24) (Brush-Hex "#9FB3C8") 132 2340 960 68
        }
        "career" {
            Draw-Text $graphics "Career Mode" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 600 60
            Draw-Pill $graphics 792 552 300 "Journeyman path" "#101C2D" "#FFD343"
            Draw-MissionCard $graphics 122 660 998 "Fix dead socket" "Beginner  |  12 min  |  Safety risk: Low" "+180 XP" "+45 coins"
            Draw-MissionCard $graphics 122 900 998 "Diagnose tripping breaker" "Intermediate  |  18 min  |  Safety risk: Medium" "+280 XP" "+70 coins"
            Draw-MissionCard $graphics 122 1140 998 "Restore lighting circuit" "Intermediate  |  20 min  |  Safety risk: Medium" "+320 XP" "+80 coins"
            Draw-MissionCard $graphics 122 1380 998 "Install EV charger" "Advanced  |  35 min  |  Safety risk: High" "+520 XP" "+140 coins"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 1680 998 380) 34
            Draw-Text $graphics "Progression" (Font-New 38 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 170 1724 620 56
            $levels = @("Apprentice", "Journeyman", "Master Electrician", "Contractor", "Company Owner")
            $ly = 1810
            foreach ($level in $levels) {
                Draw-Text $graphics $level (Font-New 28 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F5FAFF") 180 $ly 480 42
                Fill-RoundedRect $graphics (Brush-Hex "#19B7FF") (RectF 710 ($ly + 8) 300 18) 9
                $ly += 56
            }
        }
        "fault" {
            Draw-Text $graphics "Fault Diagnosis" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 680 60
            Draw-Pill $graphics 848 552 250 "03:48 left" "#101C2D" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 660 998 330) 34
            Draw-Text $graphics "Scenario" (Font-New 34 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 170 710 400 50
            Draw-Text $graphics "A kitchen socket is dead after a breaker trip. Choose safe diagnostic tools and actions to find the fault." (Font-New 29) (Brush-Hex "#D6E8F8") 170 776 770 110
            Draw-Pill $graphics 170 910 250 "Safety first" "#07111F" "#19B7FF"
            $actions = @("Visual inspection", "Voltage tester", "Multimeter", "Continuity test", "Breaker check", "Wiring diagram")
            $ay = 1060
            foreach ($action in $actions) {
                Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF 122 $ay 998 132) 26
                Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#263955"), 2)) (RectF 122 $ay 998 132) 26
                Draw-Text $graphics $action (Font-New 32 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 170 ($ay + 42) 520 44
                Draw-Pill $graphics 830 ($ay + 36) 220 "Choose" "#13273C" "#19B7FF"
                $ay += 158
            }
            Draw-Stat $graphics 122 2060 310 "Correct" "4" "#19B7FF"
            Draw-Stat $graphics 466 2060 310 "Mistakes" "1" "#FFD343"
            Draw-Stat $graphics 810 2060 310 "Score" "86%" "#19B7FF"
        }
        "wiring" {
            Draw-Text $graphics "Wiring Lab" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 600 60
            Draw-Pill $graphics 820 552 280 "Drag to connect" "#101C2D" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#0C1727") (RectF 122 660 998 1180) 34
            Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#19B7FF"), 3)) (RectF 122 660 998 1180) 34
            $nodes = @(
                @{X=250;Y=820;T="Supply"}, @{X=820;Y=820;T="Breaker"},
                @{X=250;Y=1240;T="Switch"}, @{X=820;Y=1240;T="Lamp"},
                @{X=250;Y=1660;T="Earth"}, @{X=820;Y=1660;T="Neutral"}
            )
            $wirePen1 = New-Object System.Drawing.Pen((Color-Hex "#FFD343"), 12)
            $wirePen2 = New-Object System.Drawing.Pen((Color-Hex "#19B7FF"), 12)
            $graphics.DrawLine($wirePen1, 250, 820, 820, 820)
            $graphics.DrawLine($wirePen2, 820, 1240, 820, 1660)
            $graphics.DrawLine($wirePen1, 250, 1240, 820, 1240)
            $wirePen1.Dispose()
            $wirePen2.Dispose()
            foreach ($node in $nodes) {
                Fill-RoundedRect $graphics (Brush-Hex "#162C45") (RectF ($node.X - 86) ($node.Y - 72) 172 144) 28
                Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#79E7FF"), 3)) (RectF ($node.X - 86) ($node.Y - 72) 172 144) 28
                Draw-Text $graphics $node.T (Font-New 25 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F6FAFF") ($node.X - 80) ($node.Y - 18) 160 40 "Center"
            }
            Draw-Stat $graphics 122 1940 310 "Correct" "5" "#19B7FF"
            Draw-Stat $graphics 466 1940 310 "Safety" "100%" "#FFD343"
            Draw-Stat $graphics 810 1940 310 "Time" "02:12" "#19B7FF"
            Draw-Text $graphics "Puzzle examples include lighting circuits, socket circuits, breaker panels, EV chargers, and solar inverters." (Font-New 27) (Brush-Hex "#BDD3E9") 130 2180 960 92
        }
        "quiz" {
            Draw-Text $graphics "Quiz Arena" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 600 60
            Draw-Pill $graphics 848 552 250 "Boss battle" "#101C2D" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 660 998 350) 34
            Draw-Text $graphics "Question 7 of 12" (Font-New 28 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#79E7FF") 170 712 420 42
            Draw-Text $graphics "Which test confirms continuity of a protective conductor?" (Font-New 42 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 170 776 780 120
            Draw-Pill $graphics 170 920 240 "00:18" "#07111F" "#FFD343"
            $answers = @("Insulation resistance test", "Continuity test", "Polarity check", "Earth fault loop only")
            $qy = 1080
            foreach ($answer in $answers) {
                $stroke = if ($answer -eq "Continuity test") { "#FFD343" } else { "#263955" }
                Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF 122 $qy 998 150) 28
                Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex $stroke), 3)) (RectF 122 $qy 998 150) 28
                Draw-Text $graphics $answer (Font-New 32 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F7FBFF") 170 ($qy + 48) 820 48
                $qy += 184
            }
            Draw-Stat $graphics 122 1900 310 "Score" "92%" "#19B7FF"
            Draw-Stat $graphics 466 1900 310 "Streak" "9" "#FFD343"
            Draw-Stat $graphics 810 1900 310 "XP" "+430" "#19B7FF"
            Draw-Text $graphics "Categories include safety, tools, wiring regulations, calculations, EV chargers, solar, and inspection testing." (Font-New 27) (Brush-Hex "#BDD3E9") 130 2140 960 92
        }
        "mentor" {
            Draw-Text $graphics "AI Mentor" (Font-New 46 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFFFFF") 122 552 600 60
            Draw-Pill $graphics 792 552 300 "Mock responses" "#101C2D" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 670 790 190) 34
            Draw-Text $graphics "Why was my answer wrong?" (Font-New 32 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 170 724 650 52
            Draw-Text $graphics "I chose a breaker reset before inspection." (Font-New 26) (Brush-Hex "#BDD3E9") 170 782 650 48
            Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF 330 910 790 420) 34
            Stroke-RoundedRect $graphics (New-Object System.Drawing.Pen((Color-Hex "#19B7FF"), 3)) (RectF 330 910 790 420) 34
            Draw-Text $graphics "Mentor" (Font-New 30 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 378 958 280 44
            Draw-Text $graphics "A safe diagnostic sequence starts with isolation awareness and visual inspection. Resetting a breaker before checking the circuit can hide the fault and create risk." (Font-New 29) (Brush-Hex "#D6E8F8") 378 1016 660 150
            Draw-Pill $graphics 378 1200 260 "Safety warning" "#07111F" "#FFD343"
            Fill-RoundedRect $graphics (Brush-Hex "#11263A") (RectF 122 1400 790 190) 34
            Draw-Text $graphics "Show me the formula." (Font-New 32 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#F8FCFF") 170 1460 650 52
            Draw-Text $graphics "Power, voltage, and current." (Font-New 26) (Brush-Hex "#BDD3E9") 170 1518 650 48
            Fill-RoundedRect $graphics (Brush-Hex "#0E1726") (RectF 330 1640 790 350) 34
            Draw-Text $graphics "P = V x I" (Font-New 54 ([System.Drawing.FontStyle]::Bold)) (Brush-Hex "#FFD343") 378 1698 650 70
            Draw-Text $graphics "Use formulas for practice only. Always follow local regulations, test procedures, and qualified professional guidance." (Font-New 29) (Brush-Hex "#D6E8F8") 378 1790 650 120
            Draw-Text $graphics "The AI Mentor is structured for a future real AI API, but this MVP uses local mock educational responses." (Font-New 25) (Brush-Hex "#9FB3C8") 130 2240 960 80
        }
    }

    $path = Join-Path $outDir $fileName
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    Write-Host $path
}

$screens = @(
    @{ File = "01_dashboard.png"; Title = "Train Like A Game"; Subtitle = "Level up with XP, coins, streaks, missions, and fast access to every learning mode."; Scene = "dashboard" },
    @{ File = "02_career_mode.png"; Title = "Progress From Apprentice"; Subtitle = "Unlock electrician career ranks with practical simulated missions and reward-based progression."; Scene = "career" },
    @{ File = "03_fault_diagnosis.png"; Title = "Diagnose Faults Safely"; Subtitle = "Choose tools, actions, and safety checks in timed electrical fault scenarios."; Scene = "fault" },
    @{ File = "04_wiring_lab.png"; Title = "Solve Wiring Puzzles"; Subtitle = "Practice circuit thinking with interactive wiring labs and safety-focused scoring."; Scene = "wiring" },
    @{ File = "05_quiz_arena.png"; Title = "Battle Through Quizzes"; Subtitle = "Practice safety, tools, regulations, calculations, EV chargers, solar, and testing topics."; Scene = "quiz" },
    @{ File = "06_ai_mentor.png"; Title = "Learn From Mistakes"; Subtitle = "Get mock mentor explanations for wrong answers, formulas, and safety principles."; Scene = "mentor" }
)

foreach ($screen in $screens) {
    Draw-Screenshot $screen.File $screen.Title $screen.Subtitle $screen.Scene
}
