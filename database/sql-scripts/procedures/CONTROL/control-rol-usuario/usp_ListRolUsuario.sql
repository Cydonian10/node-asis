SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolUsuario]
FECHA: 17-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar Rol usuario po control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_ListRolUsuario]
    @CONTROLID INT
AS
BEGIN
    SELECT RU.id AS id
      , RU.usuarioId_fk AS usuarioId
      , SU.cUsuario AS usuario
      , RU.rolId_fk AS rolId
      , R.cTitulo  AS rol
      , SU.cNombre +' '+ SU.cApellido  AS nombre
      , SUN.cTitulo AS unidad
      , CASE 
            WHEN EXISTS (SELECT 1 FROM ControlVacaciones cv WHERE cv.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM GradoSupervisado gs WHERE gs.rolUsuarioId_pk = RU.id)
            OR EXISTS (SELECT 1 FROM HorarioUsuario hu WHERE hu.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Justificacion j WHERE j.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Licencia l WHERE l.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Permiso p WHERE p.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Retirado r WHERE r.rolUsuarioid_fk = RU.id)
            OR EXISTS (SELECT 1 FROM TurnoModificado tm WHERE tm.rolUsuarioId_fk = RU.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM RolUsuario RU
        INNER JOIN Rol R ON RU.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SUN ON U.unidadOrgId_fk = SUN.id
        INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id
    WHERE
     NOT EXISTS (
        SELECT 1
    FROM ControlRolUsuario CRU
    WHERE 
        CRU.rolUsuarioId_fk = RU.id
        AND CRU.controlId_fk = @CONTROLID
        AND CRU.bEliminado = 0
    )
END
GO
