# Inbound Flow

## Product Master 수신

1. Relay Server에서 신규 파일 확인
2. Local Work 영역으로 Download
3. 송신 시스템의 문자 Encoding으로 읽기
4. 필요 시 UTF-8 기준 문자열로 변환
5. Header 및 Field Count 검증
6. SHA-256으로 동일 파일 처리 여부 확인
7. Staging Table Insert
8. Stored Procedure에서 업무 Validation
9. ERP Product Master Upsert
10. 성공 파일 Archive / 실패 파일 Error 이동
11. 결과 Log 기록

원본 실무 경험에는 일본계 시스템과의 문자 Encoding 차이를 처리하는 과정이 있었으며 공개 버전에서도 `shift_jis` 설정을 선택할 수 있게 구성했습니다.
