# 부록 D. ADF 표현식 Quick Reference

## 날짜/시간

| 표현식 | 결과 (예시) |
|--------|-----------|
| `@utcNow()` | 현재 UTC 시간 |
| `@formatDateTime(utcNow(), 'yyyyMMdd')` | `20260326` |
| `@formatDateTime(utcNow(), 'yyyy-MM-dd')` | `2026-03-26` |
| `@formatDateTime(utcNow(), 'yyyy/MM/dd HH:mm')` | `2026/03/26 09:30` |
| `@addDays(utcNow(), -1)` | 어제 (UTC) |
| `@addHours(utcNow(), 9)` | 한국시간 (KST = UTC+9) |
| `@formatDateTime(addHours(utcNow(),9),'yyyyMMdd')` | 한국날짜 기준 yyyyMMdd |

## 문자열

| 표현식 | 결과 |
|--------|------|
| `@concat('A', 'B', 'C')` | `ABC` |
| `@toUpper('abc')` | `ABC` |
| `@toLower('ABC')` | `abc` |
| `@replace('2026-03-26', '-', '')` | `20260326` |
| `@substring('TB_CUSTOMER', 3, 8)` | `CUSTOMER` |
| `@trim(' hello ')` | `hello` |

## 파이프라인 정보

| 표현식 | 설명 |
|--------|------|
| `@pipeline().Pipeline` | 파이프라인 이름 |
| `@pipeline().RunId` | 실행 ID |
| `@pipeline().parameters.p_table_name` | 파라메터 값 |
| `@pipeline().GroupId` | 그룹 ID |
| `@pipeline().TriggerName` | 트리거 이름 |

## Activity 참조

| 표현식 | 설명 |
|--------|------|
| `@activity('Copy_DB2_to_ADLS').output` | Copy 출력 |
| `@activity('Copy_DB2_to_ADLS').output.rowsCopied` | 복사 행 수 |
| `@activity('Copy_DB2_to_ADLS').output.dataWritten` | 쓴 데이터 크기 |
| `@activity('Copy_DB2_to_ADLS').error.message` | 에러 메시지 |

## 조건/논리

| 표현식 | 설명 |
|--------|------|
| `@if(equals(1,1), 'YES', 'NO')` | 조건식 |
| `@equals(pipeline().parameters.p_db_name, 'SAMPLEDB')` | 비교 |
| `@not(empty(pipeline().parameters.p_table_name))` | 빈 값 체크 |
| `@coalesce(pipeline().parameters.p_container, 'datalake')` | null 대체 |

## JSON / Array

| 표현식 | 설명 |
|--------|------|
| `@json('{"key":"value"}')` | JSON 파싱 |
| `@createArray('A','B','C')` | 배열 생성 |
| `@length(pipeline().parameters.p_table_list)` | 배열 길이 |
| `@item()` | ForEach 내 현재 항목 |
