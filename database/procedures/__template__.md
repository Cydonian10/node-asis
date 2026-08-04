### Modelo de Procedimiento

/*======================================================================================================
NOMBRE: [dbo].[usp_NombreDelProcedimiento]
FECHA: 24-07-2026
AUTOR: Gabriel
OBJETIVO: Descripcion del feriado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_NombreDelProcedimiento]
    -- Parametros de entrada
    @DenominacionFeriadoId INT,
    @AnioId INT,
    @Fecha DATE,

    -- Auditoria
    @UserCreador INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  -- scrit sql

END
GO