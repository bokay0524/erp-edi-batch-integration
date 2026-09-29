function Get-EdiConfig {
    param(
        [Parameter(Mandatory = $true)][string]$ConfigPath,
        [Parameter(Mandatory = $true)][string]$ProjectRoot
    )

    if (-not (Test-Path $ConfigPath)) {
        throw "Config file not found: $ConfigPath"
    }

    $config = Get-Content -Path $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json

    foreach ($name in @('outboundPath','inboundPath','archivePath','errorPath')) {
        if ($config.relay.$name -and -not [System.IO.Path]::IsPathRooted($config.relay.$name)) {
            $config.relay.$name = Join-Path $ProjectRoot $config.relay.$name
        }
    }

    return $config
}

function Get-EnvironmentValue {
    param([string]$Name, [switch]$Required)
    if ([string]::IsNullOrWhiteSpace($Name)) { return $null }
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ($Required -and [string]::IsNullOrWhiteSpace($value)) {
        throw "Required environment variable is missing: $Name"
    }
    return $value
}

Export-ModuleMember -Function Get-EdiConfig, Get-EnvironmentValue
