function AddEnvPathSession(
    [string]$addpath
    ){

    $oldpath = $Env:PATH

    if ($oldpath -like "*$addpath*") {

        Write-Information "valiable alredy in current PATH list" -InformationAction Continue
    
    } else {

        $oldpath > $PSScriptRoot\Env_Path_backup.txt
        $newpath = "$oldpath;$addpath"
        $Env:PATH = $newpath

    }

}

function AddEnvPathPermanent(
    [string]$addpath
    ){

    # windows global HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment
    # current user   HKEY_CURRENT_USER\Environment
    
    $registrypath = "Registry::HKEY_CURRENT_USER\Environment"

    $oldpath = (Get-ItemProperty -Path $registrypath -Name PATH).path

    if ($oldpath -like "*$addpath*") {

        Write-Information "valiable alredy in REGISTRY PATH list" -InformationAction Continue
    
    } else {

        $oldpath > Env_Path_backup.txt

        $newpath = "$oldpath;$addpath"

        Set-ItemProperty -Path $registrypath -Name PATH -Value $newpath

    }

}


$PathToAdd="C:\Users\czJaBeck\Dev\Applications\WezTerm\WezTerm-windows-20220624-141144-bd1b7c5d\"

AddEnvPathSession $PathToAdd
AddEnvPathPermanent $PathToAdd