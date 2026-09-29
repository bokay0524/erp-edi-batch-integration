# 운영 및 장애 복구

## 전송 실패

- ERP 송신 상태는 완료 처리하지 않음
- 실패 로그를 남기고 다음 Batch에서 재시도 가능

## 중복 수신

- 파일 SHA-256을 `EDI_FileHistory`에 기록
- 동일 Hash가 성공 처리된 경우 Skip

## 전문 오류

- Header / 필드 수 / 필수값 Validation
- 실패 파일을 `relay/error/` 영역으로 이동
- 운영자는 오류 수정 또는 원본 재수신 후 재처리 가능

## 처리 완료

- 수신 파일은 `relay/archive/`로 이동
- 원본 파일을 보존하여 추후 감사 및 재현 가능

## 로그

최소한 다음 정보를 관리하도록 설계했습니다.

- Interface
- Direction
- File Name
- File Hash
- Record Count
- Start / End Time
- Status
- Error Message
