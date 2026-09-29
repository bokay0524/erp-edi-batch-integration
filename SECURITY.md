# Security

이 저장소는 실제 기업 EDI 프로젝트의 공개용 재구현 버전입니다.

## 포함하지 않는 정보

- 실제 회사명 및 조직 코드
- 내부 IP / Hostname / 공유폴더 경로
- 실제 FTP/Relay 계정 및 Password
- 실제 ERP DB 계정 / Connection String
- 실제 Table / Stored Procedure 식별자
- 실제 해외 본사 EDI 전문 규격
- 운영 데이터 및 거래처/품목 정보

## Credential 관리

`config.example.json`에는 환경변수 이름만 포함합니다. 실제 Password나 Token을 Git에 Commit하지 않습니다.

실제 운영 프로젝트에서 사용했던 Credential이 외부에 노출된 이력이 있다면 Repository 공개 여부와 관계없이 해당 Credential을 폐기/교체하는 것이 안전합니다.

## 공개 Demo

기본 Demo는 외부 네트워크를 사용하지 않고 Repository 내부 `relay/` 폴더를 중계 서버처럼 사용합니다.
