-- ============================================================================
-- 04_config_table.sql
-- Azure SQL Database: ADF_PIPELINE_CONFIG 테이블 DDL + 샘플 데이터
-- ============================================================================
-- 실행 환경: SSMS / Azure Query Editor
-- 대상 DB  : ConfigDB (또는 기존 관리 DB)
-- ============================================================================

-- 1) Config 테이블 DDL
CREATE TABLE dbo.ADF_PIPELINE_CONFIG
(
    config_id        INT IDENTITY(1,1) PRIMARY KEY,
    source_system    VARCHAR(50)   NOT NULL,  -- 소스시스템 구분
    db_name          VARCHAR(100)  NOT NULL,  -- DB2 데이터베이스명
    schema_name      VARCHAR(100)  NOT NULL,  -- DB2 스키마명
    table_name       VARCHAR(200)  NOT NULL,  -- DB2 테이블명
    load_type        VARCHAR(20)   NOT NULL,  -- FULL / INCR
    incr_column      VARCHAR(100)  NULL,      -- 증분 기준 컬럼
    custom_query     VARCHAR(2000) NULL,      -- 커스텀 쿼리 (옵션)
    target_container VARCHAR(100)  NOT NULL,  -- ADLS 컨테이너
    is_active        BIT           NOT NULL DEFAULT 1,  -- 활성 플래그
    priority_order   INT           NOT NULL DEFAULT 100,-- 실행 순서
    description      VARCHAR(500)  NULL,      -- 설명
    created_dt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    updated_dt       DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO


-- 2) 샘플 Config 데이터
INSERT INTO dbo.ADF_PIPELINE_CONFIG
    (source_system, db_name, schema_name, table_name,
     load_type, incr_column, custom_query,
     target_container, is_active, priority_order, description)
VALUES
-- 고객 마스터 - 전체 수집
( 'DB2_ONPREM', 'SAMPLEDB', 'ETL_SCHEMA', 'TB_CUSTOMER',
  'FULL', NULL, NULL,
  'datalake', 1, 10, N'고객 마스터 전체 수집' ),

-- 주문 테이블 - 증분 수집 (UPD_DT 기준)
( 'DB2_ONPREM', 'SAMPLEDB', 'ETL_SCHEMA', 'TB_ORDER',
  'INCR', 'UPD_DT', NULL,
  'datalake', 1, 20, N'주문 데이터 일별 증분' ),

-- 상품 마스터 - 전체 수집
( 'DB2_ONPREM', 'SAMPLEDB', 'ETL_SCHEMA', 'TB_PRODUCT',
  'FULL', NULL, NULL,
  'datalake', 1, 30, N'상품 마스터 전체 수집' ),

-- 재고 테이블 - 커스텀 쿼리 수집
( 'DB2_ONPREM', 'SAMPLEDB', 'ETL_SCHEMA', 'TB_INVENTORY',
  'FULL', NULL,
  'SELECT ITEM_CD, WH_CD, QTY, UPD_DT FROM ETL_SCHEMA.TB_INVENTORY WHERE QTY > 0 WITH UR',
  'datalake', 1, 40, N'재고 > 0 건만 수집' ),

-- 로그 테이블 - 비활성 (수집 대상 아님)
( 'DB2_ONPREM', 'SAMPLEDB', 'ETL_SCHEMA', 'TB_ACCESS_LOG',
  'INCR', 'LOG_DT', NULL,
  'datalake', 0, 99, N'접속 로그 - 현재 비활성' );
GO


-- 3) 확인
SELECT * FROM dbo.ADF_PIPELINE_CONFIG ORDER BY priority_order;
