function Send-RelayFile {
    param(
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][string]$LocalFile,
        [Parameter(Mandatory = $true)][string]$RemoteFileName
    )

    if ($Config.relay.mode -eq 'LocalFolder') {
        New-Item -ItemType Directory -Force -Path $Config.relay.outboundPath | Out-Null
        $destination = Join-Path $Config.relay.outboundPath $RemoteFileName
        Copy-Item -Path $LocalFile -Destination $destination -Force
        return $destination
    }

    if ($Config.relay.mode -eq 'FTP') {
        $baseUri = [Environment]::GetEnvironmentVariable($Config.relay.baseUriEnvironmentVariable)
        $user = [Environment]::GetEnvironmentVariable($Config.relay.usernameEnvironmentVariable)
        $pass = [Environment]::GetEnvironmentVariable($Config.relay.passwordEnvironmentVariable)
        if (-not $baseUri -or -not $user -or -not $pass) { throw 'FTP environment variables are not configured.' }
        $remotePath = (($Config.relay.outboundRemotePath.Trim('/')) + '/' + $RemoteFileName).Trim('/')
        $uri = $baseUri.TrimEnd('/') + '/' + $remotePath
        $request = [System.Net.FtpWebRequest]::Create($uri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $request.Credentials = New-Object System.Net.NetworkCredential($user, $pass)
        $request.UsePassive = $true
        $request.UseBinary = $true
        $request.KeepAlive = $false
        $bytes = [System.IO.File]::ReadAllBytes($LocalFile)
        $request.ContentLength = $bytes.Length
        $stream = $request.GetRequestStream()
        try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
        $response = $request.GetResponse()
        try { return $response.StatusDescription } finally { $response.Dispose() }
    }

    throw "Unsupported relay mode: $($Config.relay.mode)"
}

function Get-InboundRelayFiles {
    param([Parameter(Mandatory = $true)]$Config, [string]$Pattern = 'PRODUCT_MASTER_*.txt')

    if ($Config.relay.mode -eq 'LocalFolder') {
        New-Item -ItemType Directory -Force -Path $Config.relay.inboundPath | Out-Null
        return @(Get-ChildItem -Path $Config.relay.inboundPath -Filter $Pattern -File | Sort-Object Name)
    }

    throw 'FTP directory listing is environment-specific and intentionally omitted from the public demo. Download adapters can be implemented against the relay specification.'
}

Export-ModuleMember -Function Send-RelayFile, Get-InboundRelayFiles
