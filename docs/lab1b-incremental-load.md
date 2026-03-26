# Lab 1-B. 변경 데이터 수집 (Incremental Load)

> **난이도:** ⭐ 입문 | **소요시간:** 30분 | **사전 조건:** [Lab 1-A](lab1a-full-load.md) 완료

## 목표

- `UPD_DT` 컬럼 기준으로 특정 날짜 범위의 변경 데이터만 추출
- 파일명에 날짜를 포함하여 일자별 Parquet 파일로 저장
- DB2 TIMESTAMP 리터럴 형식 이해

## 개념

```
TB_CUSTOMER.UPD_DT 컬럼을 기준으로
특정 날짜 범위의 변경 데이터만 추출합니다.

예: 2026-03-25 00:00:00 ≤ UPD_DT < 2026-03-26 00:00:00
    → 3월 25일에 변경된 레코드만 수집

파일명에 날짜를 포함하여 일자별 파일로 저장합니다.
datalake/SAMPLEDB/ETL_SCHEMA/TB_CUSTOMER_20260325.parquet
```

---

## 1B.1 파이프라인 생성

**파이프라인 이름:** `PL_Copy_DB2_to_ADLS_Incr_HC`

```
[Author] → [Pipelines] → [+] → [Pipeline] → [Blank Pipeline]
→ Name: PL_Copy_DB2_to_ADLS_Incr_HC
```

> **Tip:** Lab 1-A 파이프라인을 Clone하여 시작해도 됩니다.  
> `PL_Copy_DB2_to_ADLS_Full_HC` 우클릭 → Clone → 이름 변경

## 1B.2 Sink Dataset 설정 (일자별 파일명 - 하드코딩)

**Dataset 이름:** `DS_ADLS_Parquet_Customer_Incr_HC`

```
[Author] → [Datasets] → [+] → [New Dataset]
→ Type: Azure Data Lake Storage Gen2
→ Format: Parquet
→ Linked Service: LS_ADLS_Gen2
→ File Path 설정:
    Container  : datalake                          ← 하드코딩
    Directory  : SAMPLEDB/ETL_SCHEMA               ← 하드코딩
    File       : TB_CUSTOMER_20260325.parquet       ← 하드코딩
```

> Source Dataset은 Lab 1-A와 동일한 `DS_DB2_Customer_HC`를 재사용합니다.  
> Query 모드를 사용하므로 Dataset의 테이블 지정은 무관합니다.

## 1B.3 Copy Activity 구성 (변경 수집)

**Activity 이름:** `Copy_Customer_Incremental`

### Source 탭

| 설정 | 값 |
|------|-----|
| Source dataset | `DS_DB2_Customer_HC` |
| Use query | **Query** |

**Query:**
```sql
SELECT *
FROM ETL_SCHEMA.TB_CUSTOMER
WHERE UPD_DT >= '2026-03-25-00.00.00.000000'
  AND UPD_DT <  '2026-03-26-00.00.00.000000'
WITH UR
```

> ### ★ DB2 TIMESTAMP 리터럴 형식 주의
>
> DB2 TIMESTAMP 형식: `'YYYY-MM-DD-HH.MM.SS.FFFFFF'`  
> (하이픈 + 마침표 구분 — SQL Server / Oracle과 다름!)
>
> | 예시 | 결과 |
> |------|------|
> | `'2026-03-25-00.00.00.000000'` | ✅ 올바른 형식 |
> | `'2026-03-25 00:00:00'` | ❌ DB2에서 에러 발생 가능 |
>
> **대안: DB2 TIMESTAMP 함수 활용**
> ```sql
> WHERE UPD_DT >= TIMESTAMP('2026-03-25', '00:00:00')
>   AND UPD_DT <  TIMESTAMP('2026-03-26', '00:00:00')
> WITH UR
> ```

### Sink 탭

| 설정 | 값 |
|------|-----|
| Sink dataset | `DS_ADLS_Parquet_Customer_Incr_HC` |
| Copy behavior | None |
| Compression | snappy |

### Mapping / Settings 탭

Lab 1-A와 동일합니다.

## 1B.4 실행 및 검증

1. **[Debug]** 클릭 → 파이프라인 실행
2. **[Monitor]** 탭에서 실행 상태 확인
3. Activity 출력값 확인:
   - `rowsRead` / `rowsCopied`가 20건보다 적어야 정상 (변경분만 수집)
4. ADLS Gen2 파일 확인:
   ```
   datalake/SAMPLEDB/ETL_SCHEMA/TB_CUSTOMER_20260325.parquet
   ```
5. 수집 건수 교차 검증 — DB2에서 직접 확인:
   ```sql
   SELECT COUNT(*) AS INCR_CNT
   FROM ETL_SCHEMA.TB_CUSTOMER
   WHERE UPD_DT >= '2026-03-25-00.00.00.000000'
     AND UPD_DT <  '2026-03-26-00.00.00.000000'
   WITH UR;
   ```
   → ADF `rowsCopied` 값과 일치해야 합니다.

### 샘플 데이터 기준 예상 결과

UPD_DT가 2026-03-25인 레코드:

| CUSTOMER_CD | CUSTOMER_NAME | UPD_DT |
|-------------|---------------|--------|
| C-2024-0001 | 김민수 | 2026-03-25-01.00.00 |
| C-2024-0005 | (주)한국테크 | 2026-03-25-01.00.00 |
| C-2024-0007 | 한소라 | 2026-03-25-01.00.00 |
| C-2024-0010 | 강민정 | 2026-03-25-01.00.00 |
| C-2024-0012 | 임서연 | 2026-03-25-01.00.00 |
| C-2024-0014 | (주)글로벌로지스 | 2026-03-25-01.00.00 |
| C-2024-0017 | 노유진 | 2026-03-25-01.00.00 |
| C-2024-0018 | (주)세종데이터 | 2026-03-25-01.00.00 |
| C-2024-0019 | 서동현 | 2026-03-25-01.00.00 |

**예상 rowsCopied = 9건**

## 1B.5 (보충) 날짜 변경하여 재실행 테스트

다른 날짜의 변경분을 수집해 봅니다.

### 3/24 변경분 수집 테스트

1. Sink Dataset File 변경: `TB_CUSTOMER_20260324.parquet`
2. Copy Activity Source Query 변경:
   ```sql
   SELECT *
   FROM ETL_SCHEMA.TB_CUSTOMER
   WHERE UPD_DT >= '2026-03-24-00.00.00.000000'
     AND UPD_DT <  '2026-03-25-00.00.00.000000'
   WITH UR
   ```
3. Debug 실행 → 결과 확인

**예상 결과: 3건** (이영희, 미래물산, 신하늘)

4. ADLS Gen2 최종 확인:
   ```
   datalake/SAMPLEDB/ETL_SCHEMA/
   ├── TB_CUSTOMER_FULL.parquet        (Lab 1-A: 전체 20건)
   ├── TB_CUSTOMER_20260324.parquet    (Lab 1-B: 3건)
   └── TB_CUSTOMER_20260325.parquet    (Lab 1-B: 9건)
   ```

---

## Lab 1 정리: Full vs Incremental 비교

| 파이프라인 | 수집 모드 | 파일 | 행수 |
|-----------|----------|------|------|
| PL_Copy_DB2_to_ADLS_Full_HC | FULL | ..._FULL.parquet | 20 |
| PL_Copy_DB2_to_ADLS_Incr_HC | INCR (3/25) | ..._20260325.parquet | 9 |
| PL_Copy_DB2_to_ADLS_Incr_HC | INCR (3/24) | ..._20260324.parquet | 3 |

## Lab 1의 한계 (다음 Lab에서 해결)

| 한계 | 해결 Lab |
|------|---------|
| 날짜/테이블명 변경 시 Dataset과 Query를 매번 수동 수정 | [Lab 2](lab2-parameterized-pipeline.md): 파라메터로 동적 처리 |
| Full과 Incremental이 별도 파이프라인 | [Lab 2 확장](lab2-ext-lookup-foreach.md): Config load_type으로 자동 분기 |
| 수집 대상 테이블 추가 시 파이프라인 복제 필요 | [Lab 2 확장](lab2-ext-lookup-foreach.md): Lookup + ForEach로 N개 동적 처리 |
| 기존 파일 존재 시 처리 로직 없음 | [Lab 3](lab3-delete-error-handling.md): Delete Activity + 에러 핸들링 |

---

**다음 단계:** [Lab 2. 마스터-차일드 파이프라인 (파라메터화)](lab2-parameterized-pipeline.md)
