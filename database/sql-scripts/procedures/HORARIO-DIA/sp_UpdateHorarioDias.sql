--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para actualizar el HorarioDia
-- permite cambiar el estado bLibre
-- Parámetros:
-- 'IDHORARIODIA: id de hoarioDia  
-- 'LIBRE: es el estado que definie si un dia es libre dentro del horario dia
--  valor por defecto 0, si se le asigan un valor 1 el estado del dia cambiara 
--  a libre en consecuente eliminara todos los registros de las tablas relaciondas
--- con el horarioDia que se esta modificando'
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateHorarioDias]
    @IDHORARIODIA INT,
    @LIBRE BIT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Verificar si existe el HorarioDia
        IF NOT EXISTS (
            SELECT 1
            FROM HorarioDias
            WHERE id = @IDHORARIODIA AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'horario dia no encontrado';
            SET @CodeError = -1;
            RETURN;
        END

        -- Actualizar el estado de bLibre
        UPDATE HorarioDias
        SET bLibre = @LIBRE
        WHERE id = @IDHORARIODIA;

        -- Si existen TurnoRegular relacionados, marcarlos como eliminados
        IF EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE HorarioDiasId_fk = @IDHORARIODIA
        )
        BEGIN
            UPDATE TurnoRegular
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @IDHORARIODIA;
        END

        -- Si existen TurnoExtendido relacionados, marcarlos como eliminados y eliminar ConectadoDias relacionados
        IF EXISTS (
            SELECT 1
            FROM TurnoExtendido
            WHERE HorarioDiasId_fk = @IDHORARIODIA
        )
        BEGIN
            UPDATE TurnoExtendido
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @IDHORARIODIA;

            DELETE CD
            FROM ConectadoDias AS CD
            INNER JOIN TurnoExtendido AS TE ON CD.TurnoExtendidoId_pk = TE.id
            WHERE TE.bEliminado = 0 AND TE.HorarioDiasId_fk = @IDHORARIODIA;
        END

        SET @State = 1;
        SET @Message = 'dia actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
