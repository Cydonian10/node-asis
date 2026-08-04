/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosBy]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista todos los horarios por si son regulares o extendidas segun el parametro enviado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorariosBy]
  @EsExtendido BIT = NULL,
  @EsRegular BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @EsRegular = 1 AND @EsExtendido IS NULL
      BEGIN 
        SELECT 
          distinct
          h.id,
          h.cTitulo as titulo,
          h.bGeneral as general,
          h.bExtendido as extendido,
          h.bRotativo as rotativo
          -- para contar los dias asociados a cada horario
          , (
              SELECT COUNT(*) 
              FROM HorarioDias hd 
              WHERE hd.horarioId_fk = h.id
            ) AS cantidadDias
        FROM 
            Horario h  
        INNER JOIN HorarioDias hd ON h.id = hd.horarioId_fk
        INNER JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
      END
    ELSE
      BEGIN
         SELECT 
          distinct
          h.id,
          h.cTitulo as titulo,
          h.bGeneral as general,
          h.bExtendido as extendido,
          h.bRotativo as rotativo
          -- para contar los dias asociados a cada horario
          , (
              SELECT COUNT(*) 
              FROM HorarioDias hd 
              WHERE hd.horarioId_fk = h.id
            ) AS CantidadDias
        FROM 
            Horario h  
        INNER JOIN HorarioDias hd ON h.id = hd.horarioId_fk
        INNER JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
    END
END

