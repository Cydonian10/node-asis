/*======================================================================================================
NOMBRE: [dbo].[usp_GetMotivos]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Listado de motivos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMotivos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MotivoId AS motivoId,
        Nombre AS nombre,
        Descripcion AS descripcion,
        DocumentoRequerido AS documentoRequerido
    FROM Motivo
    WHERE Eliminado = 0
    ORDER BY Nombre;
END
GO
