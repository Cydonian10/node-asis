/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosDocente]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista todos los horarios de los docentes segun la temporada enviada ( los docentes
solo tienen configurado temporada ) 

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorariosDocente]
  @TEMPORADA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

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
    LEFT JOIN HorarioDias hd ON h.id = hd.horarioId_fk
  WHERE h.idTemporada is not null and h.idTemporada = @TEMPORADA_ID
END

GO

