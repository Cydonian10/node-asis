SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetGradoSupervisado]
FECHA: 06-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar grados supervisados

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetGradoSupervisado]
AS
BEGIN
    SELECT 
        GS.idGrado_pk AS idgrado,
        GS.rolUsuarioId_pk AS idusuario,
        SU.cNombre AS nombres,
        SU.cApellido AS apellidos,
        R.cTitulo AS rol,
        SGN.cGrado AS grado,
        SGN.cNivel AS nivel
    FROM GradoSupervisado GS
    INNER JOIN Sync_GradoNivel SGN ON  GS.idGrado_pk = SGN.idGrado
    INNER JOIN RolUsuario RU ON  GS.rolUsuarioId_pk = RU.id
    INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id
    INNER JOIN Rol R ON RU.rolId_fk = R.id
    WHERE GS.bEliminado = 0
END
GO
