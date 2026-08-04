/*======================================================================================================
NOMBRE: [dbo].[usp_GetVigenciasPorHorario]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista las vigencias de un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetVigenciasPorHorario]
  @HORARIO_ID INT
AS
BEGIN
  SELECT
    h.id as horarioId,
    v.tFechaInicio as fechaInicio,
    v.tFechaFin as fechaFin
  FROM
    Horario h
    INNER JOIN HorarioDias hd on h.id = hd.horarioId_fk
    INNER JOIN Vigencia v on v.horarioDiasId_fk = hd.id
  WHERE h.id = @HORARIO_ID
  GROUP BY h.id, v.tFechaFin, v.tFechaInicio
END

SELECT * FROM Horario
SELECT * FROM HorarioDias


SELECT * FROM Vigencia


-- id          horarioDiasId_fk  tFechaInicio  tFechaFin   bActivo     bTipo       bEliminado  nCreatedBy  tCreatedAt  nUpdatedBy  tUpdatedAt
-- ----------

INSERT INTO Vigencia
  (horarioDiasId_fk, tFechaInicio, tFechaFin, bActivo, bTipo, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  (1, '2026-01-01', '2026-01-31', 1, 0, 0, 1, GETDATE()),
  (2, '2026-06-01', '2026-06-30', 1, 0, 0, 1, GETDATE()),
  (3, '2026-09-01', '2026-09-30', 1, 0, 0, 1, GETDATE()),
  (4, '2026-10-01', '2026-10-31', 1, 0, 0, 1, GETDATE()),
  (5, '2026-11-01', '2026-11-30', 1, 0, 0, 1, GETDATE());

INSERT INTO Vigencia
  (horarioDiasId_fk, tFechaInicio, tFechaFin, bActivo, bTipo, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  (1, '2026-02-01', '2026-02-28', 1, 0, 0, 1, GETDATE());

