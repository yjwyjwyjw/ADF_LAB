# 부록 C. 자주 발생하는 오류 및 해결

| 오류 메시지 | 원인 | 해결 방법 |
|------------|------|----------|
| ErrorCode: 2200 `"Failed to connect to DB2"` | SHIR 서버에 DB2 ODBC 드라이버 미설치 | IBM Data Server Driver 설치 후 SHIR 재시작 |
| `"The table doesn't exist"` | Schema.Table 형식 오류 | DB2는 대문자 민감 → 정확한 케이스 확인 |
| `"Lock timeout exceeded"` | WITH UR 누락으로 락 대기 | Query에 `WITH UR` 추가 |
| `"Parquet file already exists"` | 기존 파일 존재 | Lab 3의 Delete Activity 추가 또는 Sink에서 overwrite 설정 |
| `"The expression ... is invalid"` | 작은따옴표 이스케이프 오류 | ADF에서 `'` → `''` (두 개) 사용 |
| `"Self-Hosted IR is offline"` | SHIR 서비스 중지 또는 네트워크 차단 | Integration Runtime Service 실행 상태 확인, 443 아웃바운드 포트 확인 |
| `"User not authorized"` | DB2 사용자 권한 부족 | `GRANT SELECT ON TABLE ... TO USER` 실행 |
| `"Managed Identity not authorized"` | ADLS 권한 미할당 | IAM에서 Storage Blob Data Contributor 역할 할당 확인 |
