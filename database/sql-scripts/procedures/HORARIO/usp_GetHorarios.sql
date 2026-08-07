/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar horarios (JOIN Area) con filtros opcionales de area y busqueda. Excluye Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarios]
    -- Parametros de entrada
    @areaId INT = NULL,
    @busqueda VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        H.HorarioId AS horarioId,
        H.Nombre AS nombre,
        H.AreaId AS areaId,
        A.Nombre AS areaNombre,
        A.UnidadId AS unidadId,
        H.Extendido AS extendido,
        H.Rotativo AS rotativo,
        H.Regular AS regular,
        H.HorasLaborales AS horasLaborales
    FROM Horario H
    INNER JOIN Area A ON A.AreaId = H.AreaId
    WHERE H.Eliminado = 0
        AND A.Eliminado = 0
        AND (@areaId IS NULL OR H.AreaId = @areaId)
        AND (
            @busqueda IS NULL
            OR H.Nombre LIKE '%' + @busqueda + '%'
        );
END
GO
