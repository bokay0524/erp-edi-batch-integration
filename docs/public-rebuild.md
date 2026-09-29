# 공개용 재구성 원칙

이 프로젝트는 실제 회사 EDI 소스를 그대로 공개한 Repository가 아닙니다.

다음 항목은 모두 제거 또는 일반화했습니다.

- 회사명 / 법인 코드
- 국내 및 해외 서버 IP
- FTP 계정 / 비밀번호
- 공유폴더 UNC Path
- ERP Table / Stored Procedure명
- 실제 제품 코드 및 주문 데이터
- 실제 EDI Layout

대신 실무에서 사용한 핵심 패턴인 SQL Batch, Stored Procedure, PowerShell, TXT EDI, Relay Server, Encoding 변환, 상태 및 로그 관리를 Demo 도메인으로 새로 구현했습니다.
