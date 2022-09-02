
function CreateStartMenuShortcut(
     $TargetPath
    ,$ShortcutName
    ){

    $ShortcutPath = $env:USERPROFILE + "\Start Menu\Programs\" + "$ShortcutName" + ".lnk"

    #delete short if exists
    if (Test-Path $ShortcutPath) {
        Remove-Item $ShortcutPath
    }

    $WScriptObj = New-Object -ComObject ("WScript.Shell")
    $shortcut = $WscriptObj.CreateShortcut("$ShortcutPath")
    
    $shortcut.TargetPath = "$TargetPath"
    $shortcut.Save()

    Write-Host "path:"+$shortcut.TargetPath -InformationAction Continue

}

$TargetPath =  $env:USERPROFILE + "\Dev\Applications\WezTerm\WezTerm-windows-20220624-141144-bd1b7c5d\wezterm-gui.exe"
$ShortcutName = "wezterm"

CreateStartMenuShortcut $TargetPath $ShortcutName