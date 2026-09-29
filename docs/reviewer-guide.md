# Reviewer Guide

## 5분 확인 경로

1. `README.md` Architecture 확인
2. `powershell/Send-PurchaseOrder.ps1` — Outbound 처리
3. `powershell/Receive-ProductMaster.ps1` — Inbound 처리 및 중복 방지
4. `database/procedures/` — SQL Transaction / Staging 적용
5. `docs/operations-and-recovery.md` — 장애 및 재처리 설계

## Demo

```powershell
pwsh ./powershell/Run-Demo.ps1
```

실행 후 `relay/outbound`, `relay/archive`, `samples/processed`, `logs`를 확인하면 됩니다.
