function ConvertTo-PurchaseOrderEdiLines {
    param([Parameter(Mandatory = $true)]$Rows)

    $header = 'PURCHASE_ORDER_NO|LINE_NO|ORDER_DATE|PRODUCT_CODE|QUANTITY|UNIT_PRICE|DELIVERY_DATE'
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($header)

    foreach ($row in $Rows) {
        $required = @('PURCHASE_ORDER_NO','LINE_NO','ORDER_DATE','PRODUCT_CODE','QUANTITY','UNIT_PRICE','DELIVERY_DATE')
        foreach ($column in $required) {
            if ([string]::IsNullOrWhiteSpace([string]$row.$column)) {
                throw "Required outbound field is empty: $column"
            }
        }
        $values = @(
            $row.PURCHASE_ORDER_NO,
            $row.LINE_NO,
            $row.ORDER_DATE,
            $row.PRODUCT_CODE,
            $row.QUANTITY,
            $row.UNIT_PRICE,
            $row.DELIVERY_DATE
        ) | ForEach-Object { ([string]$_).Replace('|',' ').Replace("`r",' ').Replace("`n",' ') }
        $lines.Add(($values -join '|'))
    }
    return $lines
}

function ConvertFrom-ProductMasterEdi {
    param([Parameter(Mandatory = $true)][string[]]$Lines)

    if ($Lines.Count -lt 2) { throw 'Inbound file contains no data rows.' }
    $expected = 'PRODUCT_CODE|PRODUCT_NAME|REPLACEMENT_CODE|ACTIVE'
    if ($Lines[0].Trim() -ne $expected) { throw "Unexpected inbound header: $($Lines[0])" }

    $rows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $Lines.Count; $i++) {
        if ([string]::IsNullOrWhiteSpace($Lines[$i])) { continue }
        $parts = $Lines[$i].Split('|')
        if ($parts.Count -ne 4) { throw "Invalid field count at line $($i + 1)." }
        if ([string]::IsNullOrWhiteSpace($parts[0])) { throw "PRODUCT_CODE is empty at line $($i + 1)." }
        if ($parts[3] -notin @('Y','N')) { throw "ACTIVE must be Y or N at line $($i + 1)." }
        $rows.Add([pscustomobject]@{
            PRODUCT_CODE = $parts[0].Trim()
            PRODUCT_NAME = $parts[1].Trim()
            REPLACEMENT_CODE = $parts[2].Trim()
            ACTIVE = $parts[3].Trim()
        })
    }
    return $rows
}

Export-ModuleMember -Function ConvertTo-PurchaseOrderEdiLines, ConvertFrom-ProductMasterEdi
