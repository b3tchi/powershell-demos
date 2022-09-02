function SQL-Get-Server-Instance
{
    <#
    .SYNOPSIS
    Returns the proper instance name based on the values specified either in the script
    config file, or the default values provided in the PowerShell profile file.

    .DESCRIPTION
    This is basically a utility function called by other functions for covering the case
    where the default instance is used (MSSQLSERVER). When the default instance is used,
    SQL-Get-Server-Instance will only return the server name.

    .PARAMETER DatabaseServer 
    The database server to be used (default: $global:DatabaseServer).

    .PARAMETER InstanceName 
    The instance name to be used (default: $global:InstanceName).

    .EXAMPLE
    SQL-Get-Server-Instance
    #>

    param (
        [parameter(Mandatory = $false)][string] $DatabaseServer = $global:DatabaseServer,
        [parameter(Mandatory = $false)][string] $InstanceName = $global:InstanceName
    )

    if (!$InstanceName -or $InstanceName -eq "" -or $InstanceName -eq "MSSQLSERVER")
        { return $DatabaseServer }
    else
        { return "$DatabaseServer\$InstanceName" }
}


function SQL-Script-Database
{
    <#
    .SYNOPSIS
    Script all database objects for the given database.

    .DESCRIPTION
    This  function scripts all database objects  (i.e.: tables,  views, stored
    procedures,  and user defined functions) for the specified database on the
    the given server\instance. It creates a subdirectory per object type under 
    the path specified.

    .PARAMETER savePath
    The root path where to save object definitions.

    .PARAMETER database
    The database to script (default = $global:DatabaseName)

    .PARAMETER DatabaseServer 
    The database server to be used (default: $global:DatabaseServer).

    .PARAMETER InstanceName 
    The instance name to be used (default: $global:InstanceName).

    .EXAMPLE
    SQL-Script-Database c:\temp AOIDB
    #>

    param (
        [parameter(Mandatory = $true)][string] $savePath,
        [parameter(Mandatory = $false)][string] $database = $global:DatabaseName,
        [parameter(Mandatory = $false)][string] $DatabaseServer = $global:DatabaseServer,
        [parameter(Mandatory = $false)][string] $InstanceName = $global:InstanceName
    )

    try
    {
        if (!$DatabaseServer -or !$InstanceName)
            { throw "`$DatabaseServer or `$InstanceName variable is not properly initialized" }

        $ServerInstance = SQL-Get-Server-Instance $DatabaseServer $InstanceName

        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

        $s = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerInstance)
        $db = $s.databases[$database]

        $objects = $db.Tables
        $objects += $db.Views
        $objects += $db.StoredProcedures
        $objects += $db.UserDefinedFunctions

        $scripter = New-Object ('Microsoft.SqlServer.Management.Smo.Scripter') ($s)

        $scripter.Options.AnsiFile = $true
        $scripter.Options.IncludeHeaders = $false
        $scripter.Options.ScriptOwner = $false
        $scripter.Options.AppendToFile = $false
        $scripter.Options.AllowSystemobjects = $false
        $scripter.Options.ScriptDrops = $false
        $scripter.Options.WithDependencies = $false
        $scripter.Options.SchemaQualify = $false
        $scripter.Options.SchemaQualifyForeignKeysReferences = $false
        $scripter.Options.ScriptBatchTerminator = $false

        $scripter.Options.Indexes = $true
        $scripter.Options.ClusteredIndexes = $true
        $scripter.Options.NonClusteredIndexes = $true
        $scripter.Options.NoCollation = $true

        $scripter.Options.DriAll = $true
        $scripter.Options.DriIncludeSystemNames = $false

        $scripter.Options.ToFileOnly = $true
        $scripter.Options.Permissions = $true

        foreach ($o in $objects | where {!($_.IsSystemObject)}) 
        {
            $typeFolder=$o.GetType().Name 

            if (!(Test-Path -Path "$savepath\$typeFolder")) 
                { New-Item -Type Directory -name "$typeFolder"-path "$savePath" | Out-Null }

            $file = $o -replace "\[|\]"
            $file = $file.Replace("dbo.", "")

            $scripter.Options.FileName = "$savePath\$typeFolder\$file.sql"
            $scripter.Script($o)
        }
    }

    catch
    {
        Write-Error "`t`t$($MyInvocation.InvocationName): $_"
    }
}
