# Outbound Flow

## Purchase Order 송신

1. SQL Server Agent가 정해진 시간에 Batch 시작
2. 송신 대기 상태의 ERP 발주 Header/Detail 조회
3. 공개용 EDI Staging Table로 데이터 정제
4. PowerShell이 조회 결과를 TXT 전문으로 생성
5. 필수 필드 및 개행/구분자 검사
6. SHA-256 계산
7. Relay Server Upload
8. Upload 성공 후 ERP 송신 상태를 `SENT`로 변경
9. 파일명, Hash, 처리건수 및 결과 기록

외부 Upload가 실패했는데 ERP 상태를 먼저 완료로 바꾸지 않는 것이 데이터 정합성 관점에서 중요합니다.
