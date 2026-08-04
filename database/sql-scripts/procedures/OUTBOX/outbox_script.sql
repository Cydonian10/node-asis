USE API_DATOSPERSONA_DB


CREATE TABLE kafka_outbox
(
    id BIGINT IDENTITY PRIMARY KEY,
    topic NVARCHAR(200) NOT NULL,
    [key] NVARCHAR(200) NULL,
    payload NVARCHAR(MAX) NOT NULL,
    [status] CHAR(10) NOT NULL DEFAULT 'pending',
    attempts INT NOT NULL DEFAULT 0,
    last_error NVARCHAR(500) NULL,
    retry_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    sent_at DATETIME NULL
);
CREATE INDEX IX_kafka_outbox_status_created
  ON kafka_outbox(status, created_at);

GO

CREATE OR ALTER PROCEDURE [dbo].[usp_addOutbox]
    @TOPIC AS NVARCHAR(200),
    @KEY AS NVARCHAR(200),
    @PAYLOAD AS NVARCHAR(MAX),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    SET NOCOUNT
        , XACT_ABORT ON;
    INSERT INTO kafka_outbox
        (topic, [key], payload)
    VALUES
        (@TOPIC, @KEY, @PAYLOAD)

    SET @Id =SCOPE_IDENTITY();
    SET @Message = 'Usuario creado correctamente';
    SET @CodeError = 0;
    SET @State = 1;

    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END

GO
SELECT *
FROM kafka_outbox