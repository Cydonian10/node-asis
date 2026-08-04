/*======================================================================================================
NOMBRE: [dbo].[usp_getEstadoAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener el estado de la asistencia de un usuario en una fecha determinada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getEstadoAsistencia]
AS
BEGIN
  SET NOCOUNT ON;

  SELECT id, cNombre estado FROM EstadoAsistencia;
END
