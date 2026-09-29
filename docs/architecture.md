# Architecture

## 실무 경험 기반 구조

```text
SQL Server Agent
       │
       ▼
Stored Procedure
       │
       ├─ 송수신 대상 조회 / Backup / 상태관리
       │
       └─ PowerShell Process 실행
                │
                ├─ TXT 생성 / Parsing
                ├─ Encoding 변환
                └─ Relay Server 송수신
                         │
                         ▼
                     HQ System
```

## 공개 버전 구조

공개 프로젝트에서는 실제 Server / Credential을 제거하고 Local Relay Adapter를 기본값으로 둡니다.

```text
Demo ERP CSV / SQL Server
          │
          ▼
    PowerShell Batch
          │
   ┌──────┴──────┐
   ▼             ▼
Local Relay     FTP Adapter
(default)       (optional)
   │
   ▼
Archive / Error / Log
```

실제 운영 경험을 보여주되 외부 시스템이 없어도 Reviewer가 재현할 수 있게 구성한 것이 핵심입니다.
