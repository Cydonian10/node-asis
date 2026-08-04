/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioDiaById]
FECHA: 10-10-2025
AUTOR: Vasquez Uscuvilca, Admer
OBJETIVO: Permite Obtener un horario dia por su ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioDiaById]
    @HORARIODIA_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        hd.id AS horarioDiaId,
        h.id AS horarioId,
        h.cTitulo as nombreHorario,
        d.cTitulo as dia,
        CASE WHEN hd.bLibre = 1 THEN 'SI' ELSE 'NO' END AS libre,
        v.tfechaInicio AS fechaInicio,
        v.tfechaFin AS fechaFin
    FROM HorarioDias hd
        INNER JOIN Horario h on h.id = hd.horarioId_fk
        INNER JOIN Dia d on d.id = hd.diaId_fk
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id
        -- LEFT JOIN FechaLimite fl on fl.id = v.fechaLimiteId_pk
    WHERE hd.id = @HORARIODIA_ID AND 
        h.bEliminado = 0 AND 
        hd.bEliminado = 0 AND
        d.bEliminado = 0 AND
        (v.bEliminado = 0 OR v.bEliminado IS NULL)
        -- AND (fl.bEliminado = 0 OR fl.bEliminado IS NULL);
END

