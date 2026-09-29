function Write-IntegrationLog {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][ValidateSet('INFO','WARN','ERROR')][string]$Level,
        [Parameter(Mandatory = $true)][string]$Interface,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $logDir = Join-Path $ProjectRoot 'logs'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logFile = Join-Path $logDir ("edi-{0}.log" -f (Get-Date -Format 'yyyyMMdd'))
    $line = "{0}`t{1}`t{2}`t{3}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Interface, $Message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    Write-Host $line
}

Export-ModuleMember -Function Write-IntegrationLog
