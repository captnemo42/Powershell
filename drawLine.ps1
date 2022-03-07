[void][reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[void][reflection.assembly]::LoadWithPartialName( "System.Drawing")
$Form            = New-Object Windows.Forms.Form
$Form.ClientSize = "1900,900"
$FormGraphics    = $Form.CreateGraphics()
$Pen             = new-object Drawing.Pen black
$1 = "480", "250","960","40"
$2 = "960", "250","960","40"
$3 = "1440","250","960","40"
$Form.add_paint({$FormGraphics.DrawLine($Pen, $1[0],$1[1], $1[2],$1[3])})
$Form.add_paint({$FormGraphics.DrawLine($Pen, $2[0],$2[1], $2[2],$2[3])})
$Form.add_paint({$FormGraphics.DrawLine($Pen, $3[0],$3[1], $3[2],$3[3])})
$Form.ShowDialog()
$Form.dispose()