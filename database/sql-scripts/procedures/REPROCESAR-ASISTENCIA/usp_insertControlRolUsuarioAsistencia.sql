/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlRolUsuarioAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_insertControlRolUsuarioAsistencia]
  @controlRolUsuarioId_fk INT,
  @asistenciaId_fk INT,
  @estadoAsistenciaId_fk INT,
  @marcacionEntrada DATETIME2(0),
  @marcacionSalida DATETIME2(0),
  @estadoEntrada VARCHAR(50),
  @estadoSalida VARCHAR(50),
  @usuario INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  UPDATE ControlRolUsuarioAsistencia
        SET bEliminado = 1
      WHERE asistenciaId_fk = @asistenciaId_fk;

  INSERT INTO ControlRolUsuarioAsistencia
    (controlRolUsuarioId_fk, asistenciaId_fk, estadoAsistenciaId_fk, marcacionEntrada, marcacionSalida, estadoEntrada, estadoSalida
    , nCreatedBy)
  VALUES
    (
      @controlRolUsuarioId_fk,
      @asistenciaId_fk,
      @estadoAsistenciaId_fk,
      @marcacionEntrada,
      @marcacionSalida,
      @estadoEntrada,
      @estadoSalida,
      @usuario
        );

  SELECT
    SCOPE_IDENTITY() AS Id;

  SET @Id = SCOPE_IDENTITY();
  SET @State = 1;
  SET @Message = 'Registro insertado correctamente';
  SET @CodeError = 0;
END