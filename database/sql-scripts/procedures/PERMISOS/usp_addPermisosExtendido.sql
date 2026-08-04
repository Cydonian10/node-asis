/*======================================================================================================
NOMBRE: [dbo].[usp_addPermisosTurnoExtendido]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla PermisoTurnoExtendido

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_addPermisosTurnoExtendido]
  @ROL_USUARIO_ID INT,
  @MOTIVO_ID INT,
  @FECHA DATE,
  @HORA_SALIDA TIME,
  @HORA_RETORNO_ESTIMADO TIME,
  @HORA_RETORNO_REAL TIME = NULL,
  @TURNO_EXTENDIDO_ID INT,
  @USER_ID INT,

  @State INT OUTPUT,
  @Message VARCHAR (255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @PERMISO_ID INT;

  INSERT INTO Permiso
    (rolUsuarioId_fk, motivoId_fk, tfecha, tHoraSalida, tHoraRetornoEstimado, tHoraRetornoReal, nCreatedBy)
  VALUES
    (@ROL_USUARIO_ID, @MOTIVO_ID, @FECHA, @HORA_SALIDA, @HORA_RETORNO_ESTIMADO, @HORA_RETORNO_REAL, @USER_ID);

  SET @PERMISO_ID = SCOPE_IDENTITY();

  INSERT INTO PermisoTurnoExtendido
    (permisoId_pk, turnoExtendidoId_pk, nCreatedBy)
  VALUES
    (@PERMISO_ID, @TURNO_EXTENDIDO_ID, @USER_ID);

  SET @State = 1;
  SET @Message = 'Permiso con turno extendido agregado exitosamente.';
  SET @CodeError = 0;
END

GO

