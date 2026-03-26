-- ============================================================================
-- 05_log_table.sql
-- Azure SQL Database: ADF_PIPELINE_LOG 테이블 DDL + Stored Procedure
-- ============================================================================
-- 실행 환경: SSMS / Azure Query Editor
-- 대상 DB  : ConfigDB (04_config_table.sql과 동일 DB)
-- ============================================================================

-- 1) 로그 테이블 DDL
CREATE TABLE dbo.ADF_PIPELINE_LOG
(
    log_id          INT IDENTITY(1,1) PRIMARY KEY,
    config_id       INT            NULL,
    pipeline_name   VARCHAR(200)   NOT NULL,
    run_id          VARCHAR(100)   NOT NULL,
    table_name      VARCHAR(200)   NOT NULL,
    load_date       VARCHAR(8)     NOT NULL,
    status          VARCHAR(20)    NOT NULL,  -- SUCCESS / FAILED
    rows_copied     BIGINT         NULL,
    error_message   VARCHAR(4000)  NULL,
    start_time      DATETIME2      NOT NULL,
    end_time        DATETIME2      NULL,
    duration_sec    INT            NULL
);
GO

CREATE INDEX IX_PIPELINE_LOG_DATE ON dbo.ADF_PIPELINE_LOG (load_date, status);
CREATE INDEX IX_PIPELINE_LOG_TABLE ON dbo.ADF_PIPELINE_LOG (table_name, load_date);
GO


-- 2) 에러 로그 INSERT 프로시저
CREATE PROCEDURE dbo.usp_InsertPipelineLog
    @PipelineName   VARCHAR(200),
    @RunId          VARCHAR(100),
    @TableName      VARCHAR(200),
    @LoadDate       VARCHAR(8)     = NULL,
    @Status         VARCHAR(20),
    @RowsCopied     BIGINT         = NULL,
    @ErrorMessage   VARCHAR(4000)  = NULL,
    @ExecutionTime  DATETIME2      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ADF_PIPELINE_LOG
        (pipeline_name, run_id, table_name, load_date,
         status, rows_copied, error_message, start_time)
    VALUES
        (@PipelineName, @RunId, @TableName,
         ISNULL(@LoadDate, FORMAT(GETUTCDATE(), 'yyyyMMdd')),
         @Status, @RowsCopied, @ErrorMessage,
         ISNULL(@ExecutionTime, GETUTCDATE()));
END;
GO


-- 3) 로그 조회 (최근 실행)
-- SELECT TOP 50 * FROM dbo.ADF_PIPELINE_LOG ORDER BY log_id DESC;

-- 4) 실패 건만 조회
-- SELECT * FROM dbo.ADF_PIPELINE_LOG WHERE status = 'FAILED' ORDER BY start_time DESC;
