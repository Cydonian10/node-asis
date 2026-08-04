/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar una unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteUnidad]
    @UNIDAD_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

        IF EXISTS ( SELECT 1 FROM ControlUnidad WHERE unidadId_fk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Control Unidad].'
            SET @CodeError = -1;
            RETURN; 
        END

        
        IF EXISTS ( SELECT 1 FROM Supervisor WHERE unidadId_pk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Supervisor].'
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE unidadId_fk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Rol].'
            SET @CodeError = -1;
            RETURN;
        END


        IF EXISTS ( SELECT 1 FROM UnidadFeriado WHERE unidadId_pk = @UNIDAD_ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [UnidadFeriado].'
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- Eliminación lógica
        UPDATE Unidad
            SET bEliminado = 1,
                nUpdatedBy = @USER,
                tUpdatedAt = SYSDATETIME()
            WHERE id = @UNIDAD_ID;

        SET @State = 1;
        SET @Message = 'Unidad eliminada correctamente';
        SET @CodeError = 0;
    
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
