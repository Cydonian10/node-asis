IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateLicencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateLicencia];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateLicencia]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Actualizar una licencia existente.
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateLicencia] @ID INT
    , @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @TITULO VARCHAR(250) = NULL
    , @DETALLE VARCHAR(250) = NULL
    , @FECHAINICIO DATE = NULL
    , @FECHAFIN DATE = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Licencia
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'La licencia no existe o fue eliminada.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El rolUsuario no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El motivo no existe o fue eliminado.';

            RETURN;
        END;

        IF (
                (
                    @TITULO IS NOT NULL
                    AND LTRIM(RTRIM(@TITULO)) <> ''
                    AND LEFT(@TITULO, 1) IN (' ', '-', '_')
                    )
                OR (
                    @DETALLE IS NOT NULL
                    AND LTRIM(RTRIM(@DETALLE)) <> ''
                    AND LEFT(@DETALLE, 1) IN (' ', '-', '_')
                    )
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'El título o detalle no deben iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        -- Normalizar fechas vacías o por defecto a NULL
        IF (@FECHAINICIO = '1900-01-01')
            SET @FECHAINICIO = NULL;

        IF (@FECHAFIN = '1900-01-01')
            SET @FECHAFIN = NULL;

        IF (@FECHAFIN < @FECHAINICIO)
        BEGIN
            SET @State = - 6;
            SET @Message = 'La fecha fin no puede ser menor a la fecha inicio.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND UPPER(detalle) = UPPER(@DETALLE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe una licencia, con el mismo título y detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'Ya existe una licencia con el mismo titulo.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(detalle) = UPPER(@DETALLE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una licencia con el mismo detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE rolUsuarioId_fk = @ROLUSUARIOID
                    AND id <> @ID
                    AND bEliminado = 0
                    AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
                        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
                        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
                        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe una licencia para el RolUsuario con el rango de fechas.';

            RETURN;
        END;

        UPDATE Licencia
        SET rolUsuarioId_fk = @ROLUSUARIOID
            , motivoId_fk = @MOTIVOID
            , titulo = COALESCE(NULLIF(@TITULO, ''), Titulo)
            , detalle = COALESCE(NULLIF(@DETALLE, ''), Detalle)
            , tFechaInicio = COALESCE(@FECHAINICIO, tFechaInicio)
            , tFechaFin = COALESCE(@FECHAFIN, tFechaFin)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @Id
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO


