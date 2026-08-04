IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateEstadoAsistencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateEstadoAsistencia];
GO


/*=================================================================================
NOMBRE: [dbo].[usp_UpdateEstadoAsistencia]
AUTOR: Jeandry Angulo Marquez
FECHA: 18-09-2025
OBJETIVO: Permite Actualizar datos de estado asistencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
--=================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateEstadoAsistencia] @ID INT
    , @NOMBRE VARCHAR(40)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(250) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT
        , XACT_ABORT ON;

    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE id = @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se encontro el Estado Asistenia'
            SET @CodeError = - 2;

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE cNombre = @NOMBRE
                    AND id <> @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe un estado asistencia con los mismos datos.'
            SET @CodeError = - 3;

            RETURN;
        END

        IF (
                @NOMBRE IS NOT NULL
                AND LTRIM(RTRIM(@NOMBRE)) <> ''
                )
        BEGIN
            IF (LEFT(@NOMBRE, 1) IN (' '))
            BEGIN
                SET @State = - 4;
                SET @Message = 'El nombre no puede iniciar con espacio.';

                RETURN;
            END;
        END;

        IF PATINDEX('%[^a-zA-ZÁÉÍÓÚáéíóúÑñ ]%', @NOMBRE) > 0
        BEGIN
            SET @State = - 5;
            SET @Message = 'No se permite ingresar numero, ni _, en el nombre'

            RETURN;
        END

        UPDATE EstadoAsistencia
        SET cNombre = COALESCE(NULLIF(@NOMBRE, ''), cNombre)
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = - 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
