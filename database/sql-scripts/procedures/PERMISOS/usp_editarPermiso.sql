/*======================================================================================================
NOMBRE: [dbo].[usp_editarPermiso]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar registros en la tabla Permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_editarPermiso]
  @PERMISO_ID INT,
  @MOTIVO_ID INT = NULL,
  @HORA_RETORNO_REAL TIME = NULL,
  @USER_ID INT,

  @State INT OUTPUT,
  @Message VARCHAR (255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Permiso
  SET motivoId_fk = COALESCE(@MOTIVO_ID, motivoId_fk),
      tHoraRetornoReal = COALESCE(@HORA_RETORNO_REAL, tHoraRetornoReal),
      tUpdatedAt = GETDATE(),
      nCreatedBy = @USER_ID
  WHERE id = @PERMISO_ID
    AND bEliminado = 0;

  SET @State = 1;
  SET @Message = 'Permiso actualizado exitosamente.';
  SET @CodeError = 0;
END

GO

