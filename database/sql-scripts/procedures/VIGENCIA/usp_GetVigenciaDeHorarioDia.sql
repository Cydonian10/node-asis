SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetVigenciaDeHorarioDia]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar las vigencias asociadas a un horario día

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetVigenciaDeHorarioDia]
    @HORARIO_DIA_ID INT
AS
BEGIN
    SELECT
        v.id AS id,
        --    fl.id as fechaLimiteId,
        -- v.tfechaInicio as fechaInicio,
        -- v.tfechaFin as fechaFin
        hd.id as horarioDiaId
   , h.cTitulo as horario
    , h.id as horarioId
     , CASE 
            WHEN v.bTipo = 1 THEN 'Por Día' 
            ELSE 'Por Horario'
        END AS tipoVigencia
        , d.cTitulo as dia
        , v.bActivo as activo
        , CAST(v.tfechaInicio as VARCHAR(10)) AS fechaInicio
        , CAST(v.tfechaFin as VARCHAR(10)) AS fechaFin
        , V.bEliminado
    FROM Vigencia v
        --   INNER JOIN FechaLimite fl on fl.id = v.fechaLimiteId_pk
        INNER JOIN HorarioDias hd ON  v.horarioDiasId_fk  = hd.id
        INNER JOIN Horario h ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON hd.diaId_fk = d.id
    WHERE v.horarioDiasId_fk = @HORARIO_DIA_ID AND v.bEliminado = 0
    ORDER BY v.tFechaFin DESC
END 
GO