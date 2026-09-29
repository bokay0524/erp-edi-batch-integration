$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host '=== ERP EDI Batch Integration Demo ==='

# Reset demo runtime areas.
foreach ($path in @('relay/outbound','relay/inbound','relay/archive','relay/error','samples/processed','logs','state','work')) {
    $full = Join-Path $ProjectRoot $path
    if (Test-Path $full) { Get-ChildItem $full -Force | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $full | Out-Null
}

# Simulate an inbound file arriving from headquarters.
$sampleInbound = Join-Path $ProjectRoot 'samples/inbound/PRODUCT_MASTER_20260929_140000.txt'
$relayInbound = Join-Path $ProjectRoot 'relay/inbound/PRODUCT_MASTER_20260929_140000.txt'
Copy-Item $sampleInbound $relayInbound -Force

& (Join-Path $PSScriptRoot 'Send-PurchaseOrder.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Outbound demo failed.' }

& (Join-Path $PSScriptRoot 'Receive-ProductMaster.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Inbound demo failed.' }

Write-Host ''
Write-Host 'Demo completed.'
Write-Host ('Outbound file : {0}' -f (Join-Path $ProjectRoot 'relay/outbound'))
Write-Host ('Archive       : {0}' -f (Join-Path $ProjectRoot 'relay/archive'))
Write-Host ('Processed CSV : {0}' -f (Join-Path $ProjectRoot 'samples/processed/product_master.csv'))
Write-Host ('Logs          : {0}' -f (Join-Path $ProjectRoot 'logs'))
