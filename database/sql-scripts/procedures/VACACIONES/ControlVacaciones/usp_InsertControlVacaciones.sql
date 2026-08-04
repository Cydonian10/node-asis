/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertControlVacaciones]
    @IDROLUSUARIO INT
    , @DIASDISPONIBLES INT
    , @DIASTOMADOS INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF ISNULL(@DIASDISPONIBLES, 0) < 0
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días disponibles no es válido.';

            RETURN;
        END;

        IF ISNULL(@DIASTOMADOS, 0) < 0
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días tomados no es válido.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM ControlVacaciones
                WHERE rolUsuarioId_fk = @IDROLUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            INSERT INTO ControlVacaciones (
                rolUsuarioId_fk,
                nDiasDisponibles,
                nDiasTomados,
                nCreatedBy
                )
            VALUES (
                @IDROLUSUARIO
                , @DIASDISPONIBLES
                , @DIASTOMADOS
                , @USER
                )

            SET @Id = SCOPE_IDENTITY()
            SET @AffectedRows = @@ROWCOUNT;

            IF (@AffectedRows > 0)
            BEGIN
                SET @State = 0;
                SET @Message = 'Inserción exitosa.';
            END
            ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'Fallo en la inserción.';
            END
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe un control de vacaciones para el usuario';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
