/*======================================================================================================
NOMBRE: [dbo].[usp_InsertConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Insertar un nuevo registro en ConectadoDias que sirve para extender el turno extendido.


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertConectadoDias] @TURNOEXTENDIDOID INT
    , @DIASID INT
    , @USER INT
    , @Id INT OUTPUT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOEXTENDIDOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turno extendido no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Dia
                WHERE id = @DIASID
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El día especificado no existe.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM ConectadoDias
                WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
                    AND diasId_pk = @DIASID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El registro ya existe en ConectadoDias.';

            RETURN;
        END;

        INSERT INTO ConectadoDias (
            turnoExtendidoId_pk
            , diasId_pk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @TURNOEXTENDIDOID
            , @DIASID
            , @USER
            , GETDATE()
            );

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
