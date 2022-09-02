function fx(){

    $Shell = New-Object -ComObject ("WScript.Shell")
    $Favorite = $Shell.CreateShortcut($PSScriptRoot + "\Your Shortcut.lnk")
    $Favorite.TargetPath = "%windir%\system32\notepad.exe"
    #$Favorite.Arguments = "arg1 arg2";
    $Favorite.Save()

}

fx

$env:windir
