[xml]$xaml = @"
<Window 
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
x:Name="Window"
ShowInTaskbar = "True" >    
<StackPanel>
<InkCanvas x:Name="InkCanvas" />
<StackPanel Orientation = "Horizontal" >

 <Button Width = "100" Height = "100" Background = "White" />
  <Button Width = "100" Height = "100" Background = "White"/>
   <Button Width = "100" Height = "100" Background = "White" />
</StackPanel>
</StackPanel>
</Window>
"@

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

#region Connect to Controls
$InkCanvas = $Window.FindName('InkCanvas')
#endregion Connect to Controls

	


$Window.Add_KeyDown({ 
    $Key = $_.Key  
    If ([System.Windows.Input.Keyboard]::IsKeyDown("RightCtrl") -OR [System.Windows.Input.Keyboard]::IsKeyDown("LeftCtrl")) {
        Switch ($Key) {
            "C" {$InkCanvas.CopySelection()}
            "X" {$InkCanvas.CutSelection()}
            "P" {$InkCanvas.Paste()}
            "S" {
                $SaveDialog = New-Object  Microsoft.Win32.SaveFileDialog
                $SaveDialog.Filter = "isf files (*.isf)|*.isf"
                $Result = $SaveDialog.ShowDialog()
                If ($Result){
                    $FileStream = New-Object System.IO.FileStream -ArgumentList $SaveDialog.FileName, 'Create'
                    $InkCanvas.Strokes.Save($FileStream)
                    $FileStream.Dispose()
                }                
            }
            "O" {
                $OpenDialog = New-Object Microsoft.Win32.OpenFileDialog
                $OpenDialog.Filter = "isf files (*.isf)|*.isf"
                $Result = $OpenDialog.ShowDialog()
                If ($Result) {
                    $FileStream = New-Object System.IO.FileStream -ArgumentList $OpenDialog.FileName, 'Open'
                    $StrokeCollection = New-Object System.Windows.Ink.StrokeCollection -ArgumentList $FileStream
                    $InkCanvas.Strokes.Add($StrokeCollection)
                    $FileStream.Dispose()
                }                
            }
        }
    } Else {
        Switch ($Key) {
            "C" {
                $InkCanvas.Strokes.Clear()
            }
            "S" {
                $InkCanvas.Select((new-object System.Windows.Ink.StrokeCollection))
                #$InkCanvas.Select($InkCanvas.Strokes)
            }
            "N" {
                $Color = $Script:ColorQueue.Dequeue()
                $Script:ColorQueue.Enqueue($Color)
                $InkCanvas.DefaultDrawingAttributes.Color = $Color
            }
            "Q" {
                $This.Close()
            }
            "E" {
                Switch ($InkCanvas.EditingMode) {
                    "EraseByStroke" {
                        $InkCanvas.EditingMode = 'EraseByPoint'
                    } 
                    "EraseByPoint" {
                        $InkCanvas.EditingMode = 'EraseByStroke'
                    }
                    "Ink" {
                        $InkCanvas.EditingMode = 'EraseByPoint'
                    }
                }            
            }
            "D" {
                If ($InkCanvas.DefaultDrawingAttributes.IsHighlighter) {
                    $InkCanvas.DefaultDrawingAttributes.StylusTip = 'Ellipse'
                    $InkCanvas.DefaultDrawingAttributes.Color = 'Black'
                    $InkCanvas.DefaultDrawingAttributes.IsHighlighter = $False
                    $InkCanvas.DefaultDrawingAttributes.Height = $Script:OriginalInkSize.Height
                    $InkCanvas.DefaultDrawingAttributes.Width = $Script:OriginalInkSize.Width
                    $Script:OriginalHighLightSize.Width = $InkCanvas.DefaultDrawingAttributes.Width
                    $Script:OriginalHighLightSize.Height = $InkCanvas.DefaultDrawingAttributes.Height
                }
                $InkCanvas.EditingMode = 'Ink'           
            }
            "H" {
                If (-NOT $InkCanvas.DefaultDrawingAttributes.IsHighlighter) {
                    $Script:OriginalInkSize.Width = $InkCanvas.DefaultDrawingAttributes.Width
                    $Script:OriginalInkSize.Height = $InkCanvas.DefaultDrawingAttributes.Height
                }
                $InkCanvas.EditingMode = 'Ink'
                $InkCanvas.DefaultDrawingAttributes.IsHighlighter = $True
                $InkCanvas.DefaultDrawingAttributes.Color = 'Yellow'
                $InkCanvas.DefaultDrawingAttributes.StylusTip = 'Rectangle'
                $InkCanvas.DefaultDrawingAttributes.Width = $Script:OriginalHighLightSize.Width            
                $InkCanvas.DefaultDrawingAttributes.Height = $Script:OriginalHighLightSize.Height 
            }
            "OemPlus" {
                Switch ($InkCanvas.EditingMode) {
                    "EraseByPoint" {
                        If ($InkCanvas.EraserShape.Width -lt 20) {
                            $NewSize = $InkCanvas.EraserShape.Width + 2
                            $Rectangle = New-Object System.Windows.Ink.RectangleStylusShape -ArgumentList $NewSize,$NewSize
                            $InkCanvas.EraserShape = $Rectangle
                            $InkCanvas.EditingMode = 'None'
                            $InkCanvas.EditingMode = 'EraseByPoint'
                        }                
                    }
                    "Ink" {
                        If ($InkCanvas.DefaultDrawingAttributes.Height -lt 20) {
                            $InkCanvas.DefaultDrawingAttributes.Height = $InkCanvas.DefaultDrawingAttributes.Height + 2
                            $InkCanvas.DefaultDrawingAttributes.Width = $InkCanvas.DefaultDrawingAttributes.Width + 2
                            $InkCanvas.EditingMode = 'None'
                            $InkCanvas.EditingMode = 'Ink'
                        }
                    }
                }
                     
            }
            "OemMinus" {
                Switch ($InkCanvas.EditingMode) {
                    "EraseByPoint" {
                        If ($InkCanvas.EraserShape.Width -gt 2) {
                            $NewSize = $InkCanvas.EraserShape.Width - 2
                            $Rectangle = New-Object System.Windows.Ink.RectangleStylusShape -ArgumentList $NewSize,$NewSize
                            $InkCanvas.EraserShape = $Rectangle
                            $InkCanvas.EditingMode = 'None'
                            $InkCanvas.EditingMode = 'EraseByPoint'
                        }
                    }
                    "Ink" {
                        If ($InkCanvas.DefaultDrawingAttributes.Height -gt 2) {
                            $InkCanvas.DefaultDrawingAttributes.Height = $InkCanvas.DefaultDrawingAttributes.Height - 2
                            $InkCanvas.DefaultDrawingAttributes.Width = $InkCanvas.DefaultDrawingAttributes.Width - 2
                            $InkCanvas.EditingMode = 'None'
                            $InkCanvas.EditingMode = 'Ink'
                        }
                    }
                }            
            }
        }
    }
         
})

[void]$Window.ShowDialog()