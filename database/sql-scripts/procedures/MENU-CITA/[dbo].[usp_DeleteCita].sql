IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_DeleteCita'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_DeleteCita];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO:Procedimiento para eliminar de forma logica el registro de una cita por ID

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteCita] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    IF NOT EXISTS (
            SELECT 1
            FROM Cita
            WHERE id = @ID
                AND bEliminado = 0
            )
    BEGIN
        SET @State = - 2;
        SET @Message = 'La cita no existe o ya fue eliminada.';

        RETURN;
    END;

    IF EXISTS (
            SELECT 1
            FROM Cita
            WHERE id = @ID
                AND bCancelado = 0
                AND bEliminado = 0
            )
    BEGIN
        SET @State = - 3;
        SET @Message = 'No se puede eliminar una cita que está en uso o activa.';

        RETURN;
    END;

    IF @USER IS NULL
        OR @USER <= 0
    BEGIN
        SET @State = - 4;
        SET @Message = 'El usuario que realizo la eliminacion no es válido.';

        RETURN;
    END;

    UPDATE Cita
    SET nUpdatedBy = @USER
        , tUpdatedAt = GETDATE()
        , bEliminado = 1
    WHERE id = @ID

    IF (@@ROWCOUNT > 0)
    BEGIN
        SET @State = 0;
        SET @Message = 'Eliminación exitosa';
    END
    ELSE
    BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la eliminación';
    END
END
GO


