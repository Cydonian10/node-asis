/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkMigrarSyncUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Migrar una unidad sincronizada a la tabla Unidad. Si @SyncUnidadId es NULL, migra todos
          los registros de SyncUnidad que aun no tienen fila en Unidad. Inserta con horas por
          defecto (8 / 40). Respeta el UNIQUE de Unidad.SyncUnidadId.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkMigrarSyncUnidad]
    -- Parametros de entrada
    @SyncUnidadId INT = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF @SyncUnidadId IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SyncUnidad WHERE SyncUnidadId = @SyncUnidadId)
            BEGIN
                SET @State = -1;
                SET @Message = 'La unidad sincronizada no existe';
                SET @CodeError = -1;
                RETURN;
            END

            IF EXISTS (SELECT 1 FROM Unidad WHERE SyncUnidadId = @SyncUnidadId)
            BEGIN
                SET @State = -1;
                SET @Message = 'La unidad sincronizada ya fue migrada';
                SET @CodeError = -1;
                RETURN;
            END
        END

        BEGIN TRANSACTION;

        IF @SyncUnidadId IS NOT NULL
        BEGIN
            INSERT INTO Unidad (SyncUnidadId, HorasLaborales, HorasLaboralesTotales)
            VALUES (@SyncUnidadId, 8, 40);

            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Unidad migrada correctamente';
        END
        ELSE
        BEGIN
            INSERT INTO Unidad (SyncUnidadId, HorasLaborales, HorasLaboralesTotales)
            SELECT SU.SyncUnidadId, 8, 40
            FROM SyncUnidad SU
            LEFT JOIN Unidad U ON U.SyncUnidadId = SU.SyncUnidadId
            WHERE U.UnidadId IS NULL;

            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Unidades migradas correctamente';
        END

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
