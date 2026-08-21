/*======================================================================================================
NOMBRE: [dbo].[usp_GetMotivoById]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener Motivo por id

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMotivoById]
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MotivoId AS motivoId,
        Nombre AS nombre,
        Descripcion AS descripcion,
        DocumentoRequerido AS documentoRequerido
    FROM Motivo
    WHERE MotivoId = @ID
      AND Eliminado = 0;
END
GO
