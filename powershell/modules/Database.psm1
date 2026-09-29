function Get-DbConnectionInfo {
    param([Parameter(Mandatory = $true)]$Config)
    if (-not $Config.database.enabled) { return $null }

    if ($Config.database.serverEnvironmentVariable) {
        $server = [Environment]::GetEnvironmentVariable($Config.database.serverEnvironmentVariable)
        $database = [Environment]::GetEnvironmentVariable($Config.database.databaseEnvironmentVariable)
        $username = [Environment]::GetEnvironmentVariable($Config.database.usernameEnvironmentVariable)
        $password = [Environment]::GetEnvironmentVariable($Config.database.passwordEnvironmentVariable)
    } else {
        $server = $Config.database.server
        $database = $Config.database.database
    }

    if (-not $server -or -not $database) { throw 'Database server/name is not configured.' }
    return [pscustomobject]@{
        Server = $server
        Database = $database
        Username = $username
        Password = $password
        Integrated = [bool]$Config.database.useIntegratedSecurity
    }
}

function Invoke-EdiQuery {
    param([Parameter(Mandatory = $true)]$Connection, [Parameter(Mandatory = $true)][string]$Query)
    Import-Module SqlServer -ErrorAction Stop
    if ($Connection.Integrated) {
        return Invoke-Sqlcmd -ServerInstance $Connection.Server -Database $Connection.Database -Query $Query -TrustServerCertificate
    }
    $secure = ConvertTo-SecureString $Connection.Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($Connection.Username, $secure)
    return Invoke-Sqlcmd -ServerInstance $Connection.Server -Database $Connection.Database -Query $Query -Credential $cred -TrustServerCertificate
}

Export-ModuleMember -Function Get-DbConnectionInfo, Invoke-EdiQuery
