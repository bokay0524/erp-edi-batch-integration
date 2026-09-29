# Public EDI File Specification

실제 회사 EDI 전문은 공개하지 않습니다. 이 저장소에서는 Portfolio Demo를 위해 일반화한 Pipe-delimited 형식을 사용합니다.

## PURCHASE_ORDER

Encoding: UTF-8 (No BOM 권장)

| Field | Description | Example |
|---|---|---|
| PURCHASE_ORDER_NO | 발주번호 | PO-2026-0001 |
| LINE_NO | Line 번호 | 1 |
| ORDER_DATE | 발주일자 YYYYMMDD | 20260929 |
| PRODUCT_CODE | 품목코드 | PRD-1001 |
| QUANTITY | 수량 | 10 |
| UNIT_PRICE | 단가 | 125.50 |
| DELIVERY_DATE | 납기일 YYYYMMDD | 20261005 |

## PRODUCT_MASTER

Encoding: UTF-8 Demo / `shift_jis` 선택 가능

| Field | Description | Example |
|---|---|---|
| PRODUCT_CODE | 품목코드 | PRD-1001 |
| PRODUCT_NAME | 품목명 | Digital Gauge A |
| REPLACEMENT_CODE | 대체 품목 | PRD-2001 |
| ACTIVE | 사용여부 | Y |
