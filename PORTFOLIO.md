# ERP EDI Batch Integration — Portfolio Summary

## 프로젝트 개요

국내 ERP와 해외 본사 시스템 간 발주·제품 기준정보 등의 데이터를 정기적으로 송수신하기 위한 File-based EDI Batch Integration 프로젝트입니다.

SQL Server Agent와 Stored Procedure를 이용해 지정된 시간에 연동 프로세스를 시작하고, PowerShell을 통해 ERP 데이터를 TXT 규격으로 변환해 중계 서버로 전송하거나 본사에서 전달된 TXT 파일을 수신하여 ERP DB에 반영하도록 구성했습니다.

## 담당 기술

- SQL Server / T-SQL
- Stored Procedure
- SQL Server Agent Batch
- PowerShell
- TXT File Integration
- Relay Server / FTP
- Encoding Conversion
- Integration Logging

## 핵심 구현

### Outbound

ERP 송신 대상 조회 → 데이터 정제 → EDI TXT 생성 → 중계 서버 Upload → 성공 로그 → ERP 송신상태 변경

### Inbound

중계 서버 신규 파일 확인 → Download → Encoding 변환 → TXT Parsing → Validation → Staging 적재 → ERP 반영 → Archive

## 기술적 포인트

- 외부 전송 성공 이후에만 ERP 송신 완료 상태로 변경하여 데이터 불일치 방지
- 수신 파일 Hash를 기록하여 동일 파일 중복 처리 방지
- 파일 처리 결과와 건수를 Integration Log에 저장하여 Batch 추적 가능
- 처리 완료 / 오류 파일을 분리해 재처리 운영이 가능하도록 구성
- 일본계 시스템에서 사용하는 문자 Encoding을 고려한 변환 처리 경험

## 공개용 프로젝트

실제 회사의 서버 주소, Credential, ERP Table, Stored Procedure 및 EDI 전문 규격은 공개하지 않고 업무 흐름을 일반화한 Demo 프로젝트로 재구현했습니다.
