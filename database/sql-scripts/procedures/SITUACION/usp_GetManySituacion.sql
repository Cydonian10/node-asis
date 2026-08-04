IF EXISTS (
  SELECT * 
   FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
   AND SPECIFIC_NAME = N'usp_GetManySituacion'
   AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_GetManySituacion]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetManySituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista todas las situaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetManySituacion]
AS
BEGIN

  SELECT s.id, s.cNombre nombre, s.nOrden orden,  (
    SELECT COUNT(*) 
    FROM ProyectoSituacion ps
    WHERE ps.id_situacion_fk = s.id
      AND ps.bEliminado = 0
  ) 
  AS uso FROM Situacion s
    WHERE bEliminado = 0
END
GO

