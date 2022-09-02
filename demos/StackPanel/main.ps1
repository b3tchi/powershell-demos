Function Get-UIElementLookup {
    $i=0
    $Script:uiElement = [ordered]@{}
    $StackPanel.Children | ForEach {$uiElement[$_.Name]=$i;$i++}
}

#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen"
    SizeToContent = "WidthAndHeight" ShowInTaskbar = "True" Background = "lightgray"> 
    <StackPanel Orientation = 'Horizontal'>  
        <Button x:Name = 'CloseButton' MinWidth = "400" Content = 'Giant Button of Closing' FontSize = '30' 
        Background = 'Black' Foreground = 'White' FontWeight = 'Bold'/> 
        <StackPanel x:Name="StackPanel" Margin = "50,50,50,50" Background = 'White'>
            <Button x:Name = "button1" Height = "75" Width = "150" Content = 'Right -> Left' Background="Yellow" />
            <Button x:Name = "button2" Height = "75" Width = "150" Content = 'Left -> Right' Background="Yellow" />  
            <Label x:Name = "label1" Height = "75" Width = "300" Background="MidnightBlue" Foreground = "White"              
            HorizontalContentAlignment = 'Center' VerticalContentAlignment = 'Center'/> 
            <Button x:Name = "button3" Height = "75" Width = "150" Content = 'Horizontal' Background="Red" /> 
            <Button x:Name = "button4" Height = "75" Width = "150" Content = 'Vertical' Background="Red" />                                               
            <StackPanel x:Name = 'childstackpanel' Orientation = 'Horizontal'>                       
                <Button x:Name = "button5" Height = "75" Width = "150" Content = 'Add New Label' Background="White" />         
                <Button x:Name = "button6" Height = "75" Width = "150" Content = 'Hide Button5' Background="White" />
                <Canvas Height = '80' Width = '100'>
                    <Label Content = "Label in canvas" Background = 'LightGreen'/>
                </Canvas>
            </StackPanel>
        </StackPanel>
    </StackPanel>
</Window>
"@
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

#Connect to Controls
$button1 = $Window.FindName("button1")
$button2 = $Window.FindName("button2")
$button3 = $Window.FindName("button3")
$button4 = $Window.FindName("button4")
$button5 = $Window.FindName("button5")
$button6 = $Window.FindName("button6")
$CloseButton = $Window.FindName("CloseButton")
$label1 = $Window.FindName("label1")
$StackPanel = $Window.FindName("StackPanel")

$window.Add_Loaded({
    $label1.Content = ("Orientation: {0}`nFlowDirection: {1}" -f $StackPanel.Orientation,$StackPanel.FlowDirection)
    $Script:newLabelExists = $False
    Get-UIElementLookup
})

$Button1.Add_Click({
    $StackPanel.FlowDirection = "RightToLeft"
    $label1.Content = ("Orientation: {0}`nFlowDirection: {1}" -f $StackPanel.Orientation,$StackPanel.FlowDirection)
})
$Button2.Add_Click({
    $StackPanel.FlowDirection = "LeftToRight"
    $label1.Content = ("Orientation: {0}`nFlowDirection: {1}" -f $StackPanel.Orientation,$StackPanel.FlowDirection)
})
$Button3.Add_Click({
    $StackPanel.Orientation = "Horizontal"
    $label1.Content = ("Orientation: {0}`nFlowDirection: {1}" -f $StackPanel.Orientation,$StackPanel.FlowDirection)
})
$Button4.Add_Click({
    $StackPanel.Orientation = "Vertical"
    $label1.Content = ("Orientation: {0}`nFlowDirection: {1}" -f $StackPanel.Orientation,$StackPanel.FlowDirection)
})
$button5.Add_Click({
    If ($Script:newLabelExists) {
        $StackPanel.Children.RemoveAt($uiElement.NewLabel)
        $button5.Content = "Add New Label"
        $Script:newLabelExists = $False
        Get-UIElementLookup
    } Else {
        $newLabel = New-Object System.Windows.Controls.Label
        $newLabel.Content = 'New Label'
        $newLabel.Background = Get-Random ('Green','Red','Black','Blue')
        $newLabel.Foreground = 'White'
        $newLabel.Name = 'NewLabel'
        #randomly insert it into the StackPanel
        $StackPanel.Children.Insert((0..$StackPanel.Children.count | Get-Random),$newLabel)   
        $button5.Content = "Remove New Label"
        $Script:newLabelExists = $True
        Get-UIElementLookup
    }
})
$Button6.Add_Click({    
    Switch ($button5.Visibility) {
        'Visible' {
            $button6.Content = 'Show Button5'
            $button5.Visibility = 'Hidden'
        }
        'Hidden' {
            $button6.Content = 'Hide Button5'
            $button5.Visibility = 'Visible'
        }
    }
})
$CloseButton.Add_Click({
    $Window.Close()
})
$Window.Showdialog() | Out-Null