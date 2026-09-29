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
$interface = 'PURCHASE_ORDER_OUTBOUND'
$workDir = Join-Path $ProjectRoot 'work/outbound'
New-Item -ItemType Directory -Force -Path $workDir | Out-Null

try {
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'START'

    if ($config.mode -eq 'Demo') {
        $source = Join-Path $ProjectRoot 'samples/source/purchase_orders.csv'
        $rows = @(Import-Csv -Path $source)
    } else {
        $conn = Get-DbConnectionInfo -Config $config
        $rows = @(Invoke-EdiQuery -Connection $conn -Query 'EXEC dbo.usp_edi_prepare_outbound_purchase_order;')
    }

    if ($rows.Count -eq 0) {
        Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'NO DATA'
        exit 0
    }

    $fileName = 'PURCHASE_ORDER_{0}.txt' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
    $localFile = Join-Path $workDir $fileName
    $lines = ConvertTo-PurchaseOrderEdiLines -Rows $rows
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($localFile, $lines, $encoding)
    $hash = (Get-FileHash -Path $localFile -Algorithm SHA256).Hash

    $result = Send-RelayFile -Config $config -LocalFile $localFile -RemoteFileName $fileName
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message ("UPLOAD SUCCESS file={0} rows={1} sha256={2}" -f $fileName, $rows.Count, $hash)

    if ($config.mode -ne 'Demo') {
        $safeFile = $fileName.Replace("'", "''")
        $safeHash = $hash.Replace("'", "''")
        Invoke-EdiQuery -Connection $conn -Query "EXEC dbo.usp_edi_complete_outbound_purchase_order @FileName=N'$safeFile', @FileHash='$safeHash';" | Out-Null
    }

    Remove-Item -Path $localFile -Force
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level INFO -Interface $interface -Message 'STOP SUCCESS'
}
catch {
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level ERROR -Interface $interface -Message $_.Exception.Message
    Write-IntegrationLog -ProjectRoot $ProjectRoot -Level ERROR -Interface $interface -Message 'STOP FAILED'
    exit 1
}
