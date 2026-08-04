IF EXISTS (
  SELECT * 
   FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
   AND SPECIFIC_NAME = N'usp_GetOneSituacion'
   AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_GetOneSituacion]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Descripcion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetOneSituacion]
  @ID INT
AS
BEGIN
  SELECT id, cNombre nombre, nOrden orden FROM Situacion
    WHERE id = @ID and bEliminado = 0
END
GO
