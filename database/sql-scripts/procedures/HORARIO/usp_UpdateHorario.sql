/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Actualizar un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateHorario] 
    @ID INT
    , @TITULO VARCHAR(50) = NULL
    , @HORADIA VARCHAR(5) = NULL
    , @GENERAL BIT
    , @EXTENDIDO BIT
    , @ROTATIVO BIT
    , @REGULAR BIT
    , @TEMPORADA_ID INT = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF NOT EXISTS (
                SELECT 1
                FROM Horario
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El horario no existe o ha sido eliminado';

            RETURN
        END

        IF (
                @TITULO IS NOT NULL
                AND LTRIM(RTRIM(@TITULO)) <> ''
                )
        BEGIN
            IF (LEFT(@TITULO, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El título no puede iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF (
                @HORADIA IS NOT NULL
                AND @HORADIA <> ''
                AND @HORADIA LIKE '[ -_]%'
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La hora no puede iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF (
                @HORADIA IS NOT NULL
                AND LTRIM(RTRIM(@HORADIA)) IN ('0', '00', '00:00')
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Debe registrar una hora válida (no "0", "00" ni "00:00").';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND horaDia = @HORADIA
                    AND id <> @Id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya esta en uso el título y horaDia en otro horario.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND id <> @Id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya esta en uso el titulo en otro horario.';

            RETURN;
        END

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Horario
        --         WHERE horaDia = @HORADIA
        --             AND id <> @Id
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 8;
        --     SET @Message = 'Ya esta en uso el hora en otro horario.';
        --     RETURN;
        -- END
        UPDATE Horario
        SET cTitulo = COALESCE(NULLIF(@TITULO, ''), cTitulo)
            , horaDia = COALESCE(NULLIF(@HORADIA, ''), horaDia)
            , bGeneral = COALESCE(@GENERAL, bGeneral)
            , bExtendido = COALESCE(@EXTENDIDO, bExtendido)
            , bRotativo = COALESCE(@ROTATIVO, bRotativo)
            , bRegular = COALESCE(@REGULAR, bRegular)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
            , idTemporada = COALESCE(@TEMPORADA_ID, idTemporada)
        WHERE id = @Id
            AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
