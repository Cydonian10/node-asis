IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateBiometrico'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateBiometrico];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite actualizar un biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateBiometrico] @ID INT
    , @MARCA VARCHAR(100) = NULL
    , @TIPOBD VARCHAR(50) = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (
                @MARCA IS NOT NULL
                AND LTRIM(RTRIM(@MARCA)) <> ''
                )
        BEGIN
            IF (LEFT(@MARCA, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 2;
                SET @Message = 'La marca no deben iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF (
                @TIPOBD IS NOT NULL
                AND LTRIM(RTRIM(@TIPOBD)) <> ''
                )
        BEGIN
            IF (LEFT(@TIPOBD, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El tipoBD, no puede iniciar con espacio, "-" ni "_"  '

                RETURN;
            END;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El biométrico no existe o está eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe, un biometrico con estos datos.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe, esta marca registrada'

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe, el tipoBD registrado'

            RETURN;
        END

        UPDATE Biometrico
        SET marca = COALESCE(NULLIF(@MARCA, ''), marca)
            , tipoBD = COALESCE(NULLIF(@TIPOBD, ''), tipoBD)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se actualizó ningún registro.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO


