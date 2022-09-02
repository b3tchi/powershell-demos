#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Computer Information" WindowStartupLocation = "CenterScreen"
    SizeToContent = "WidthAndHeight" ShowInTaskbar = "True" Background = "lightgray" ResizeMode = "NoResize"> 
    <StackPanel Orientation = 'Horizontal' >  
        <StackPanel x:Name = "StackPanel" Margin = "5" Background = 'White'>
            <Button x:Name = "osButton" Height = "75" Width = "150" Content = 'OS Details' Background="Yellow" />
            <Button x:Name = "diskspaceButton" Height = "75" Width = "150" Content = 'Disk Space' Background="Yellow" />  
            <Button x:Name = "biosButton" Height = "75" Width = "150" Content = 'BIOS' Background="Yellow" /> 
            <Button x:Name = "netinfoButton" Height = "75" Width = "150" Content = 'Network Information' Background="Yellow" /> 
        </StackPanel>    
        <Label x:Name = 'label1' Width = "400" FontSize = '15'
        Background = 'Black' Foreground = 'White' FontWeight = 'Bold'/> 
    </StackPanel>
</Window>
"@
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

#Connect to Controls
$osButton = $Window.FindName("osButton")
$diskspaceButton = $Window.FindName("diskspaceButton")
$biosButton = $Window.FindName("biosButton")
$netinfoButton = $Window.FindName("netinfoButton")
$label1 = $Window.FindName("label1")
$StackPanel = $Window.FindName("StackPanel")

$osButton.Add_Click({
    $data = Get-WmiObject -Class Win32_OperatingSystem |  ForEach {
        New-Object PSObject -Property @{
            Computername = $env:computername
            OS = $_.Caption
            Version = $_.Version
            SystemDirectory = $_.systemdirectory
            Serialnumber = $_.serialnumber
            InstalledOn = ($_.ConvertToDateTime($_.InstallDate))            
            LastReboot = ($_.ConvertToDateTime($_.LastBootUpTime))            
        }
    }
    $label1.Content = $data | Out-String
})

$diskspaceButton.Add_Click({
    $data = Get-WmiObject -Class Win32_LogicalDisk | ForEach {
        New-Object PSObject -Property @{
            DeviceID = $_.DeviceID
            TotalSpace = ("{0} GB" -f ($_.Size /1GB))
            FreeSpace = ("{0} GB" -f ($_.FreeSpace /1GB))
            VolumeName = $_.VolumeName
            DriveType = $_.DriveType
        }
    }
    $label1.Content = $Data | Out-String
})

$biosButton.Add_Click({
    $data = Get-WmiObject -Class Win32_Bios| ForEach {
        New-Object PSObject -Property @{
            BIOSStatus = $_.Status
            Version = $_.SMBIOSBIOSVersion
            Manufacturer = $_.Manufacturer
            SerialNumber = $_.SerialNumber
            ReleaseDate = ($_.ConvertToDateTime($_.ReleaseDate)) 
        }
    }
    $label1.Content = $Data | Out-String    
})

$netinfoButton.Add_Click({
    $netInfo = Get-WmiObject -Class win32_networkadapterconfiguration | Where {
        $_.IPAddress -match "(\d{1,3}\.){3}\d{1,3}"
    }
    $related = @($netInfo.GetRelated())
    $Data = $netInfo | ForEach {
        New-Object PSObject -Property @{
            IPAddress = ($_.IPAddress | Out-String)
            DefaultGateway = ($_.DefaultIPGateway | Out-String)
            MAC = $_.MACAddress
            Subnet = ($_.IPSubnet | Out-String)
            DNS = ($_.DNSServerSearchOrder | Out-String)
            DHCP = $_.DHCPServer
            ID = $related[0].NetConnectionID
            Speed = ("{0}" -f ($related[0].Speed))
        }
    }
    $label1.Content = $Data | Out-String    
})

$Window.ShowDialog() | Out-Null