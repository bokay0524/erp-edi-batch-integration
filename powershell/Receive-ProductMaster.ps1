param(
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path $PSScriptRoot -Parent
if (-not $ConfigPath) { $ConfigPath = Join-Path $ProjectRoot 'config.demo.json' }

Import-Module (Join-Path $PSScriptRoot 'modules/Config.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules/IntegrationLog.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules/EdiFormat.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules/FileTransfer.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules/Database.psm1') -Force

$config = Get-EdiConfig -ConfigPath $ConfigPath -ProjectRoot $ProjectRoot
$interface = 'PRODUCT_MASTER_INBOUND'
$stateFile = Join-Path $ProjectRoot 'state/processed-files.json'
New-Item -ItemType Directory -Force -Path (Split-Path $stateFile -Parent) | Out-Null

if (Test-Path $stateFile) {
    $processed = @(Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json)
} else {
    $processed = @()
}

try {
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'START'
    $files = @(Get-InboundRelayFiles -Config $config -Pattern 'PRODUCT_MASTER_*.txt')
    if ($files.Count -eq 0) {
        Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'NO FILE'
        exit 0
    }

    foreach ($file in $files) {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        if ($processed -contains $hash) {
            Write-IntegrationLog -ProjectRoot $ProjectRoot -Level WARN -Interface $interface -Message ("DUPLICATE SKIP file={0}" -f $file.Name)
            continue
        }

        try {
            $encodingName = [string]$config.inboundEncoding
            if ($encodingName -eq 'shift_jis') {
                [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)
                $encoding = [System.Text.Encoding]::GetEncoding(932)
            } else {
                $encoding = [System.Text.Encoding]::UTF8
            }
            $lines = [System.IO.File]::ReadAllLines($file.FullName, $encoding)
            $rows = @(ConvertFrom-ProductMasterEdi -Lines $lines)

            if ($config.mode -eq 'Demo') {
                $output = Join-Path $ProjectRoot 'samples/processed/product_master.csv'
                $rows | Export-Csv -Path $output -NoTypeInformation -Encoding UTF8
            } else {
                $conn = Get-DbConnectionInfo -Config $config
                foreach ($row in $rows) {
                    $code = $row.PRODUCT_CODE.Replace("'", "''")
                    $name = $row.PRODUCT_NAME.Replace("'", "''")
                    $replacement = $row.REPLACEMENT_CODE.Replace("'", "''")
                    $active = $row.ACTIVE.Replace("'", "''")
                    Invoke-EdiQuery -Connection $conn -Query "EXEC dbo.usp_edi_stage_inbound_product_master @ProductCode=N'$code', @ProductName=N'$name', @ReplacementCode=N'$replacement', @Active='$active', @FileHash='$hash';" | Out-Null
                }
                Invoke-EdiQuery -Connection $conn -Query "EXEC dbo.usp_edi_apply_inbound_product_master @FileHash='$hash';" | Out-Null
            }

            $archiveDir = $config.relay.archivePath
            New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null
            Move-Item -Path $file.FullName -Destination (Join-Path $archiveDir $file.Name) -Force
            $processed += $hash
            @($processed) | ConvertTo-Json | Set-Content -Path $stateFile -Encoding UTF8
            Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message ("PROCESS SUCCESS file={0} rows={1} sha256={2}" -f $file.Name, $rows.Count, $hash)
        }
        catch {
            $errorDir = $config.relay.errorPath
            New-Item -ItemType Directory -Force -Path $errorDir | Out-Null
            if (Test-Path $file.FullName) { Move-Item -Path $file.FullName -Destination (Join-Path $errorDir $file.Name) -Force }
            Write-IntegrationLog -ProjectRoot $ProjectRoot -Level ERROR -Interface $interface -Message ("PROCESS FAILED file={0} message={1}" -f $file.Name, $_.Exception.Message)
        }
    }

    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'STOP'
}
catch {
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level ERROR -Interface $interface -Message $_.Exception.Message
    exit 1
}
