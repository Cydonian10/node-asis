/*======================================================================================================
NOMBRE: [dbo].[usp_GetDias]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar el catalogo de dias (7 filas: Lunes..Domingo). Es catalogo fijo, solo lectura.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetDias]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        D.DiaId AS diaId,
        D.Nombre AS nombre,
        D.Abreviatura AS abreviatura,
        D.Orden AS orden
    FROM Dia D
    WHERE D.Eliminado = 0
    ORDER BY D.Orden;
END
GO
