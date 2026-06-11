Add-Type -AssemblyName System.Drawing

function New-Icon($size, $outFile) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Background rounded rect
    $bg = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r = [int]($size * 0.18)
    $bg.AddArc(0, 0, $r*2, $r*2, 180, 90)
    $bg.AddArc($size-$r*2-1, 0, $r*2, $r*2, 270, 90)
    $bg.AddArc($size-$r*2-1, $size-$r*2-1, $r*2, $r*2, 0, 90)
    $bg.AddArc(0, $size-$r*2-1, $r*2, $r*2, 90, 90)
    $bg.CloseFigure()
    $cBg = [System.Drawing.Color]::FromArgb(255, 13, 13, 13)
    $brushBg = New-Object System.Drawing.SolidBrush($cBg)
    $g.FillPath($brushBg, $bg)

    # Grid lines
    $cGrid = [System.Drawing.Color]::FromArgb(20, 0, 200, 150)
    $gridPen = New-Object System.Drawing.Pen($cGrid)
    $gridPen.Width = 1
    $margin = [int]($size * 0.15)
    $top = [int]($size * 0.25)
    $chartH = [int]($size * 0.5)
    for ($i = 0; $i -le 4; $i++) {
        $y = $top + [int]($chartH / 4 * $i)
        $g.DrawLine($gridPen, $margin, $y, $size - $margin, $y)
    }

    # Chart polyline
    $cGreen = [System.Drawing.Color]::FromArgb(255, 0, 200, 150)
    $cPen = New-Object System.Drawing.Pen($cGreen)
    $cPen.Width = [Math]::Max(2, [int]($size * 0.015))
    $cPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $x0 = $margin
    $x1 = $size - $margin
    $xw = $x1 - $x0
    $yBot = $top + $chartH

    $pts = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pts.StartFigure()
    $pts.AddLine($x0, $yBot - $chartH*0.2, $x0 + $xw*0.17, $yBot - $chartH*0.45)
    $pts.AddLine($x0 + $xw*0.17, $yBot - $chartH*0.45, $x0 + $xw*0.28, $yBot - $chartH*0.35)
    $pts.AddLine($x0 + $xw*0.28, $yBot - $chartH*0.35, $x0 + $xw*0.42, $yBot - $chartH*0.75)
    $pts.AddLine($x0 + $xw*0.42, $yBot - $chartH*0.75, $x0 + $xw*0.50, $yBot - $chartH*0.65)
    $pts.AddLine($x0 + $xw*0.50, $yBot - $chartH*0.65, $x0 + $xw*0.62, $yBot - $chartH*0.90)
    $pts.AddLine($x0 + $xw*0.62, $yBot - $chartH*0.90, $x0 + $xw*0.72, $yBot - $chartH*0.80)
    $pts.AddLine($x0 + $xw*0.72, $yBot - $chartH*0.80, $x0 + $xw*0.85, $yBot - $chartH*0.95)
    $pts.AddLine($x0 + $xw*0.85, $yBot - $chartH*0.95, $x1, $yBot - $chartH*0.88)
    $g.DrawPath($cPen, $pts)

    # End dot
    $lastPt = $pts.PathPoints[$pts.PathPoints.Length - 1]
    $dotR = [Math]::Max(3, [int]($size * 0.02))
    $cGreenTrans = [System.Drawing.Color]::FromArgb(100, 0, 200, 150)
    $brushDot = New-Object System.Drawing.SolidBrush($cGreenTrans)
    $g.FillEllipse($brushDot, $lastPt.X - $dotR, $lastPt.Y - $dotR, $dotR*2, $dotR*2)
    $brushDot2 = New-Object System.Drawing.SolidBrush($cGreen)
    $g.FillEllipse($brushDot2, $lastPt.X - $dotR*0.6, $lastPt.Y - $dotR*0.6, $dotR*1.2, $dotR*1.2)

    # LD text
    $fs = [int]($size * 0.14)
    $f = New-Object System.Drawing.Font("Segoe UI", $fs, [System.Drawing.FontStyle]::Bold)
    $brushText = New-Object System.Drawing.SolidBrush($cGreen)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $textY = [int]($size * 0.83)
    $g.DrawString("LD", $f, $brushText, $size/2, $textY, $fmt)

    $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $brushBg.Dispose()
    $brushDot.Dispose()
    $brushDot2.Dispose()
    $brushText.Dispose()
    $bg.Dispose()
    $pts.Dispose()
    Write-Output "Generated $outFile"
}

New-Icon 192 "icon-192.png"
New-Icon 512 "icon-512.png"
