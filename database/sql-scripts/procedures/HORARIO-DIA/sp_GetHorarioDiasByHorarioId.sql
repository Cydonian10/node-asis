
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetHorarioDiasByHorarioId]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para Mostrar un horariodia a partir del id
-- Parámetros:
-- 'HORARIOID: Es id de un horario dia existente 
-- 'MOSTRARTODO: estado para poder visualizar todos los registros de la tabla independiete
--  si tiene o no una vigencia asisgnada'
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetHorarioDiasByHorarioId]
    @IDHORARIO INT,
    @MOSTRARTODO BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        hd.id AS horarioDiaId,
        h.id AS horarioId,
        h.cTitulo AS nombreHorario,
        d.cTitulo AS dia,
        d.id as diaId,
        h.horaDia as horarioDia,
        --CASE WHEN hd.bLibre = 1 THEN 'SI' ELSE 'NO' END AS libre,
        hd.bLibre AS libre,
        CAST(MAX(v.tfechaInicio) AS VARCHAR(10)) AS fechaInicio,
        CAST(MAX(v.tfechaFin) AS VARCHAR(10)) AS fechaFin
    FROM HorarioDias AS hd
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia AS v ON v.horarioDiasId_fk = hd.id AND ISNULL(v.bEliminado, 0) = 0
    -- LEFT JOIN FechaLimite AS fl ON fl.id = v.fechaLimiteId_pk AND ISNULL(fl.bEliminado, 0) = 0
    WHERE 
            hd.horarioId_fk = @IDHORARIO
        AND hd.bEliminado = 0
        AND (
                    @MOSTRARTODO = 1
        OR (
                            v.tfechaInicio <= CONVERT(DATE, GETDATE())
        AND v.tfechaFin >= CONVERT(DATE, GETDATE())
                    )
            )
    GROUP BY hd.id, h.id, h.cTitulo, d.cTitulo, hd.bLibre, d.orden, d.id, h.horaDia
    ORDER BY d.orden ASC;
END
GO


