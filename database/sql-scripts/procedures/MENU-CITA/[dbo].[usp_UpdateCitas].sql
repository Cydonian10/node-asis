IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateCitas'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateCitas];
GO

/*======================================================================================================
Nombre: [dbo].[usp_UpdateCitas]
Autor: Jeandry Angulo Marquez
Fecha: 26-09-2025
OBJETIVO: Procedimiento para actualizar 

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
 -    -             -             -
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateCitas] @ID INT
    , @HORARIOUSUARIOID INT = NULL
    , @NOMBRE VARCHAR(250) = NULL
    , @DESCRIPCION VARCHAR(250) = NULL
    , @FECHA DATE = NULL
    , @HORA TIME = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @fechagn DATE;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El registro no existe o ya fue eliminado.';

            RETURN;
        END;

        -- Normalizar fechas vacías o por defecto a NULL
        IF (@FECHA = '1900-01-01')
            SET @FECHA = NULL;

        IF (
                @HORA IS NULL
                OR FORMAT(@HORA, 'HH:mm') = '00:00'
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Debe ingresar una hora válida distinta de 00:00.';

            RETURN;
        END;

        IF (
                @NOMBRE IS NOT NULL
                AND LTRIM(RTRIM(@NOMBRE)) <> ''
                )
        BEGIN
            IF (LEFT(@NOMBRE, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El tipoBD, no puede iniciar con espacio, "-" ni "_"  '

                RETURN;
            END;
        END;

        IF (
                @DESCRIPCION IS NOT NULL
                AND LTRIM(RTRIM(@DESCRIPCION)) <> ''
                )
        BEGIN
            IF (LEFT(@DESCRIPCION, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 4;
                SET @Message = 'La marca no deben iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe una cita con el mismo nombre.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe una cita con el mismo descripcion.';

            RETURN;
        END;

        SELECT @fechagn = fecha
        FROM Cita
        WHERE id = @ID

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = COALESCE(@FECHA, @fechagn)
                    AND hora = @HORA
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'la hora ya fue registrada'

            RETURN;
        END

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Cita
        --         WHERE fecha = COALESCE(@FECHA, @fechaActual)
        --             AND hora = @HORA
        --             AND id <> @ID
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 9;
        --     SET @Message = 'Ya existe una cita registrada en la misma fecha y hora.';
        --     RETURN;
        -- END;
        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = @FECHA
                    AND hora = @HORA
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una cita registrada en la misma fecha y hora.';

            RETURN;
        END;

        UPDATE Cita
        SET horarioUsuarioId_fk = COALESCE(@HORARIOUSUARIOID, horarioUsuarioId_fk)
            , nombre = COALESCE(NULLIF(@NOMBRE, ''), nombre)
            , cDescripcion = COALESCE(NULLIF(@DESCRIPCION, ''), cDescripcion)
            , fecha = COALESCE(@FECHA, fecha)
            , hora = COALESCE(@HORA, hora)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización realizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se realizaron cambios en el registro.';
        END;
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO


