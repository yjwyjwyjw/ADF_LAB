# 부록 A. 사전 준비사항 (Prerequisites)

## Azure 리소스

| 리소스 | 설명 |
|--------|------|
| Azure Data Factory V2 | 파이프라인 오케스트레이션 |
| ADLS Gen2 스토리지 계정 | Hierarchical Namespace 활성화, 컨테이너: `datalake` |
| Azure SQL Database | Config / Log 테이블용 (Lab 2 확장부터) |
| Resource Group | 모든 리소스 동일 RG 권장 |

## 온-프레미스

| 항목 | 상세 |
|------|------|
| IBM DB2 서버 | v11.x 이상 권장 |
| 테스트 DB | `SAMPLEDB` |
| 테스트 Schema | `ETL_SCHEMA` |
| 테스트 Table | `TB_CUSTOMER` (아래 DDL 참고) |
| SHIR | Self-Hosted Integration Runtime 설치 완료, 상태 "Running" |
| DB2 드라이버 | SHIR 서버에 IBM DB2 ODBC/OLE DB 드라이버 설치 필수 |

## Linked Service 사전 생성

### 1) LS_DB2_OnPrem

| 설정 | 값 |
|------|-----|
| Type | IBM DB2 |
| Integration Runtime | Self-Hosted IR |
| Server / Database / Auth | 온-프레미스 DB2 접속정보 |

### 2) LS_ADLS_Gen2

| 설정 | 값 |
|------|-----|
| Type | Azure Data Lake Storage Gen2 |
| Authentication | Managed Identity 또는 Account Key |
| URL | `https://<storageaccount>.dfs.core.windows.net` |

## Dataset 사전 생성

| Dataset | Type | 용도 |
|---------|------|------|
| `DS_DB2_Table` | DB2 테이블 | `LS_DB2_OnPrem` 연결 |
| `DS_ADLS_Parquet` | ADLS Gen2 Parquet | `LS_ADLS_Gen2` 연결 |

---

## DB2 실습 테이블 생성 및 샘플 데이터

> SQL 스크립트 파일:
> - DDL: [sql/01_create_tb_customer.sql](../sql/01_create_tb_customer.sql)
> - INSERT: [sql/02_insert_sample_data.sql](../sql/02_insert_sample_data.sql)
> - 검증: [sql/03_verify_queries.sql](../sql/03_verify_queries.sql)

DB2 CLP, IBM Data Studio, DBeaver 등에서 `SAMPLEDB`에 CONNECT 한 후 실행하세요.

### 샘플 데이터 설계 (20건)

| 항목 | 포함 내용 |
|------|----------|
| 고객유형 | 개인(P) 16건 + 기업(B) 4건 |
| 성별 | M 8건, F 8건, NULL 4건(기업) |
| 상태 | 활성(A) 16건, 비활성(I) 2건, 탈퇴(D) 1건 |
| 등급 | A=5, B=6, C=4, D=2, E=1 |
| 멤버십 | VIP=3, GOLD=4, SILVER=4, BASIC=9 |
| 지역 | 서울 6, 경기 5, 부산/광주/대전/제주/인천/울산/전주/강원/세종 각 1 |
| NULL값 | EMAIL NULL 2건, ADDRESS_DETAIL NULL 5건, LAST_LOGIN_DT NULL 1건, REMARK NULL 10건 |
| 날짜분포 | UPD_DT: 2026-02-15 ~ 2026-03-26 (증분수집 테스트용) |
| 금액 | CREDIT_LIMIT 300만~2억, TOTAL_PURCHASE 5만~1.45억 (소수점 검증) |
| 한글/영문 | 전 건 한글+영문 이름 포함 (인코딩 검증) |
