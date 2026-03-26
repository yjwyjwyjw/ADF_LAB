# 부록 B. Linked Service / Dataset 설정 참고

## DB2 Linked Service 상세 설정 (LS_DB2_OnPrem)

| 설정 | 값 |
|------|-----|
| Type | IBM DB2 |
| Connect via IR | `<Self-Hosted IR 이름>` |
| Server | `<DB2 서버 IP 또는 호스트명>` |
| Database | `SAMPLEDB` |
| Authentication | Basic |
| Username | `<DB2 사용자>` |
| Password | Azure Key Vault 참조 권장 |
| Port | 50000 (기본) |

> **SHIR 서버에 IBM Data Server Driver 설치 필요**
> - 다운로드: IBM Fix Central → "IBM Data Server Driver Package"
> - 설치 후 SHIR 서비스 재시작

## ADLS Gen2 Linked Service 상세 설정 (LS_ADLS_Gen2)

| 설정 | 값 |
|------|-----|
| Type | Azure Data Lake Storage Gen2 |
| Connect via IR | AutoResolveIntegrationRuntime (Azure IR) |
| Authentication | Managed Identity (권장) 또는 Account Key |
| URL | `https://<account>.dfs.core.windows.net` |

> **Managed Identity 사용 시:**
> ADF의 Managed Identity에 ADLS Gen2 **"Storage Blob Data Contributor"** 역할 할당 필요 (IAM에서 설정)

## 전체 Dataset 목록

| Dataset Name | Type | 용도 |
|-------------|------|------|
| `DS_DB2_Customer_HC` | DB2 | Lab 1 하드코딩 Source |
| `DS_ADLS_Parquet_Customer_Full_HC` | ADLS | Lab 1-A 하드코딩 Sink (Full) |
| `DS_ADLS_Parquet_Customer_Incr_HC` | ADLS | Lab 1-B 하드코딩 Sink (Incr) |
| `DS_DB2_Parameterized` | DB2 | Lab 2~4 파라메터화 Source |
| `DS_ADLS_Parquet_Parameterized` | ADLS | Lab 2~4 파라메터화 Sink |
| `DS_AzureSQL_Config` | Azure SQL | Lab 2 확장 Config Lookup |
