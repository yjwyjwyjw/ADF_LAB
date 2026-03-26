# Lab 1-A. 전체 데이터 수집 (Full Load)

> **난이도:** ⭐ 입문 | **소요시간:** 30분 | **사전 조건:** [부록 A](appendix-a-prerequisites.md) 완료

## 목표

- 가장 단순한 Copy Activity 파이프라인 생성
- DB2 테이블 전체를 ADLS Gen2에 Parquet으로 수집
- **Query 모드 + WITH UR** 사용법 이해
- 모든 값을 하드코딩하여 기본 동작 확인

## Full Load vs Incremental Load

| 구분 | Full Load (이번 Lab) | Incremental Load (Lab 1-B) |
|------|---------------------|---------------------------|
| 수집 범위 | 테이블 전체 행 | 변경분만 (UPD_DT 기준) |
| SQL | `SELECT * ... WITH UR` | `SELECT * WHERE UPD_DT >= ...` |
| Sink 모드 | Overwrite (덮어쓰기) | Overwrite (일자별 파일) |
| 파일 경로 | `.../TB_CUSTOMER_FULL` | `.../TB_CUSTOMER_20260325` |
| 적합 대상 | 마스터 테이블 (소량) | 트랜잭션 테이블 (대량) |

---

## 1A.1 파이프라인 생성

**파이프라인 이름:** `PL_Copy_DB2_to_ADLS_Full_HC`

```
[Author] → [Pipelines] → [+] → [Pipeline] → [Blank Pipeline]
→ Name: PL_Copy_DB2_to_ADLS_Full_HC
```

## 1A.2 Source Dataset 설정 (DB2 테이블 - 하드코딩)

**Dataset 이름:** `DS_DB2_Customer_HC`

```
[Author] → [Datasets] → [+] → [New Dataset]
→ Type: IBM DB2
→ Linked Service: LS_DB2_OnPrem
→ Table: ETL_SCHEMA.TB_CUSTOMER       ← 하드코딩
→ Import Schema: "From connection/store" 선택
```

## 1A.3 Sink Dataset 설정 (ADLS Parquet - 하드코딩)

**Dataset 이름:** `DS_ADLS_Parquet_Customer_Full_HC`

```
[Author] → [Datasets] → [+] → [New Dataset]
→ Type: Azure Data Lake Storage Gen2
→ Format: Parquet
→ Linked Service: LS_ADLS_Gen2
→ File Path 설정:
    Container  : datalake                      ← 하드코딩
    Directory  : SAMPLEDB/ETL_SCHEMA           ← 하드코딩
    File       : TB_CUSTOMER_FULL.parquet      ← 하드코딩
```

> **Note:** Full Load는 매번 덮어쓰므로 파일명에 날짜를 넣지 않습니다. 실행할 때마다 동일 파일을 최신 스냅샷으로 교체합니다.

## 1A.4 Copy Activity 구성 (전체 수집)

**Activity 이름:** `Copy_Customer_Full`

```
[Activities] → [Move & transform] → Copy data → 캔버스에 드래그
```

### Source 탭

| 설정 | 값 |
|------|-----|
| Source dataset | `DS_DB2_Customer_HC` |
| Use query | **Query** ← "Table" 대신 "Query" 선택 |

**Query:**
```sql
SELECT * FROM ETL_SCHEMA.TB_CUSTOMER WITH UR
```

> ### ★ "Table" 모드 vs "Query" 모드
>
> | 모드 | 설명 |
> |------|------|
> | **Table 모드** | ADF가 자동으로 `SELECT * FROM 테이블` 생성 → DB2에서 `WITH UR`을 붙일 수 없음 **(락 대기 위험!)** |
> | **Query 모드** | 직접 SQL 작성 가능 → `WITH UR` 추가하여 Uncommitted Read로 수집, WHERE 절·컬럼 선택·TRIM/COALESCE 등 자유 작성 |
>
> **결론: DB2 소스에서는 항상 "Query" 모드 + `WITH UR` 을 사용하세요.**

### Sink 탭

| 설정 | 값 |
|------|-----|
| Sink dataset | `DS_ADLS_Parquet_Customer_Full_HC` |
| Copy behavior | None (기본값 — 파일 덮어쓰기) |
| Compression | **snappy** (권장, 압축률과 속도의 균형) |

### Mapping 탭

`[Import schemas]` 클릭 → 자동 매핑 확인

27개 컬럼 자동 매핑 결과 검토:

| DB2 컬럼 (타입) | Parquet 타입 |
|-----------------|-------------|
| CUSTOMER_ID (int) | INT32 |
| CUSTOMER_CD (varchar) | UTF8 |
| BIRTH_DATE (date) | DATE |
| CREDIT_LIMIT (decimal) | DECIMAL |
| UPD_DT (timestamp) | TIMESTAMP_MILLIS |

### Settings 탭

| 설정 | 값 |
|------|-----|
| Data integration units | Auto |
| Degree of copy parallelism | (기본값) |

## 1A.5 실행 및 검증

1. **[Debug]** 클릭 → 파이프라인 실행
2. **[Monitor]** 탭에서 실행 상태 확인 — Status: `Succeeded`
3. Activity 출력값 확인 (Monitor → Activity → 안경 아이콘):
   - `rowsRead` : 20 (DB2에서 읽은 행 수)
   - `rowsCopied` : 20 (ADLS에 쓴 행 수)
   - `dataRead` / `dataWritten` : 바이트 수 확인
   - `copyDuration` : 소요 시간
4. ADLS Gen2 파일 확인:
   ```
   datalake/SAMPLEDB/ETL_SCHEMA/TB_CUSTOMER_FULL.parquet
   ```
5. (선택) 파일 내용 검증 — Databricks/Synapse:
   ```sql
   SELECT COUNT(*) FROM parquet.`abfss://datalake@<account>.dfs.core.windows.net/SAMPLEDB/ETL_SCHEMA/TB_CUSTOMER_FULL.parquet`
   ```
6. 한 번 더 Debug 실행 → 파일이 **덮어쓰기** 되는지 확인

---

**다음 단계:** [Lab 1-B. 변경 데이터 수집 (Incremental Load)](lab1b-incremental-load.md)
