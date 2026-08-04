/*======================================================================================================
NOMBRE: [dbo].[usp_InsertHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar nuevos horarios

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertHorario] @TITULO VARCHAR(50)
    , @HORADIA DECIMAL(10,2)
    , @GENERAL BIT
    , @EXTENDIDO BIT
    , @ROTATIVO BIT
    , @REGULAR BIT
    , @TEMPORADA_ID INT=NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (LTRIM(RTRIM(ISNULL(@TITULO, ''))) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'El titulo no puede estar vacío.';

            RETURN;
        END;

        IF (
                LEFT(@TITULO, 1) = ' '
                OR LEFT(@TITULO, 1) IN ('-', '_')
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El título no puede iniciar con espacio, "-" o "_".';

            RETURN;
        END;


        IF (
                @HORADIA IS NULL
                OR @HORADIA <= 0
                )
            OR @HORADIA > 24
        BEGIN
            SET @State = - 4;
            SET @Message = 'Debe registrar un valor válido para hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND horaDia = @HORADIA
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe un horario con este título y hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'El título ya está en uso en otro horario.';

            RETURN;
        END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Horario
        --         WHERE horaDia = @HORADIA
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 7;
        --     SET @Message = 'La hora ya está en uso en otro horario.';

        --     RETURN;
        -- END;

        INSERT INTO Horario (
            cTitulo
            , horaDia
            , bGeneral
            , bExtendido
            , bRotativo
            , nCreatedBy
            , tCreatedAt
            , bRegular
            , idTemporada
            )
        VALUES (
            @TITULO
            , @HORADIA
            , @GENERAL
            , @EXTENDIDO
            , @ROTATIVO
            , @USER
            , GETDATE()
            , @REGULAR
            , @TEMPORADA_ID
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
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
