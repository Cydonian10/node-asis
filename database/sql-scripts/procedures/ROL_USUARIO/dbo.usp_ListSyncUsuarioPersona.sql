IF EXISTS (
        SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'usp_ListSyncUsuarioPersona'
    AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_ListSyncUsuarioPersona]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListSyncUsuarioPersona]
FECHA: 14-11-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar usuarios sin rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ListSyncUsuarioPersona]
AS
BEGIN
    SELECT
        SU.id id,
        SU.cUsuario usuario,
        SU.cNombre nombre,
        SU.cApellido apellido,
        SU.cTipo tipo,
        SU.cDni dni
    FROM Sync_Usuario SU
END
GO
