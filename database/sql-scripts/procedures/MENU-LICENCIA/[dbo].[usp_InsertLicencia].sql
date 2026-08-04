IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertLicencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertLicencia];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar una licencia para un usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertLicencia] @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @TITULO VARCHAR(250)
    , @DETALLE VARCHAR(250)
    , @FECHAINICIO DATE
    , @FECHAFIN DATE
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF (
                @TITULO IS NULL
                OR LTRIM(RTRIM(@TITULO)) = ''
                OR @DETALLE IS NULL
                OR LTRIM(RTRIM(@DETALLE)) = ''
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'Los campos no puede ser nulos ni vacíos.';

            RETURN;
        END;

        IF (
                @FECHAINICIO IS NULL
                OR @FECHAFIN IS NULL
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Las fechas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                LEFT(@TITULO, 1) IN (' ', '-', '_')
                OR LEFT(@DETALLE, 1) IN (' ', '-', '_')
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El título y el detalle no puede iniciar con espacio, "-" o "_".';

            RETURN;
        END;

        IF (@FECHAFIN < @FECHAINICIO)
        BEGIN
            SET @State = - 5;
            SET @Message = 'La fechaFin no puede ser menor a la fechaInicio.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
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
            SET @State = - 7;
            SET @Message = 'El motivo no existe o fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND UPPER(detalle) = UPPER(@DETALLE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'Ya existe una licencia, con el mismo título y detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una licencia con el mismo titulo.';

            RETURN;
        END; 

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(detalle) = UPPER(@DETALLE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe una licencia con el mismo detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE rolUsuarioId_fk = @ROLUSUARIOID
                    AND bEliminado = 0
                    AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
                        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
                        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
                        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
            SET @State = - 11;
            SET @Message = 'Ya existe un registro para el rolUsuario en el rango de fechas.';

            RETURN;
        END;

        INSERT INTO Licencia (
            rolUsuarioId_fk
            , motivoId_fk
            , titulo
            , detalle
            , tFechaInicio
            , tFechaFin
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @ROLUSUARIOID
            , @MOTIVOID
            , @TITULO
            , @DETALLE
            , @FECHAINICIO
            , @FECHAFIN
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO


