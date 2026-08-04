/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlUnidadAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de unidad para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   26-02-2026  Gabriel    Se agrega parámetro @nMinutosTarde para registrar minutos de tardanza
====================================================================================================== 
CREATE OR ALTER PROCEDURE [dbo].[usp_insertControlUnidadAsistencia]
  @controlUnidadId_fk INT,
  @asistenciaId_fk INT,
  @estadoAsistenciaId_fk INT,
  @marcacionEntrada DATETIME2(0),
  @marcacionSalida DATETIME2(0),
  @estadoEntrada VARCHAR(50),
  @estadoSalida VARCHAR(50),
  @nMinutosTarde INT = 0,
  @usuario INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  UPDATE ControlUnidadAsistencia
        SET bEliminado = 1
      WHERE asistenciaId_fk = @asistenciaId_fk;

  INSERT INTO ControlUnidadAsistencia
    (controlUnidadId_fk, asistenciaId_fk, estadoAsistenciaId_fk, marcacionEntrada, marcacionSalida, estadoEntrada, estadoSalida, nMinutosTarde, nCreatedBy)
  VALUES
    (
      @controlUnidadId_fk,
      @asistenciaId_fk,
      @estadoAsistenciaId_fk,
      @marcacionEntrada,
      @marcacionSalida,
      @estadoEntrada,
      @estadoSalida,
      @nMinutosTarde,
      @usuario
        );


  SET @Id = SCOPE_IDENTITY();
  SET @State = 1;
  SET @Message = 'Registro insertado correctamente';
  SET @CodeError = 0;
END
