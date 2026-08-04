SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Eliminar un registro en ConectadoDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteConectadoDias] @TURNOEXTENDIDOID INT
    , @DIASID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOEXTENDIDOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoExtendido no existe o está eliminado.';

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

        IF NOT EXISTS (
                SELECT 1
                FROM ConectadoDias
                WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
                    AND diasId_pk = @DIASID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El registro ConectadoDias no existe.';

            RETURN;
        END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM TurnoExtendido AS TE
        --         INNER JOIN HorarioDias AS HD
        --             ON TE.horarioDiasId_fk = HD.id
        --             AND HD.bEliminado = 0
        --         WHERE TE.id = @TURNOEXTENDIDOID
        --             AND TE.bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 5;
        --     SET @Message = 'El turnoExtendido está en uso, no se puede eliminar.';

        --     RETURN;
        -- END;

        DELETE
        FROM ConectadoDias
        WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
            AND diasId_pk = @DIASID;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Falla al eliminar.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
