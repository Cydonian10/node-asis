CREATE OR ALTER PROCEDURE [dbo].[usp_GetVigenciaGlobal]
    @HORARIO_ID INT
AS
BEGIN

    SELECT
        ROW_NUMBER() OVER (ORDER BY h.id , v.tfechaInicio)AS idFila,
        h.id AS horarioId,
        h.cTitulo AS titulo,
        CAST(v.tfechaInicio AS VARCHAR(10)) AS fechaInicio,
        CAST( v.tfechaFin AS VARCHAR(10))AS fechaFin,
        COUNT(hd.id) AS total_dias,
        CASE 
            WHEN v.bTipo = 1 THEN 'Por Día' 
            ELSE 'Por Horario'
        END AS TipoVigencia,
        CASE 
            WHEN v.bActivo = 1 THEN 'si' else 'no' end as activo
    FROM Vigencia v
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        INNER JOIN Horario h ON hd.horarioId_fk = h.id
    WHERE h.id = @HORARIO_ID
        AND v.bEliminado = 0
        AND h.bEliminado = 0
        AND v.bActivo = 1
    GROUP BY 
    h.id, 
    h.cTitulo,
    v.tFechaInicio, 
    v.tFechaFin,
    v.bTipo,
    v.bActivo
END
GO