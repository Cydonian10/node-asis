SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlesRolUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles de rolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_GetControlesRolUsuario]
    @ROL_CONTROL_ID INT
AS
BEGIN
    SELECT 
        cru.id AS id,
        cru.rolUsuarioId_fk AS rolUsuarioId,
        cru.controlId_fk AS controlId,
        R.cTitulo AS rol,
        SU.cUsuario AS usuario,
        SU.cNombre+' '+SU.cApellido AS nombre,
        SUN.cTitulo AS unidad,
        c.nLimiteFalta AS limiteFalta,
        c.nLimiteMarcacion AS limiteMarcacion,
        c.nTolerancia AS tolerancia,
        CASE 
            WHEN EXISTS (SELECT 1 FROM ControlRolUsuarioAsistencia CRUA WHERE CRUA.controlRolUsuarioId_fk = cru.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM ControlRolUsuario cru
        INNER JOIN CONTROLES c on c.Id = cru.controlId_fk
        INNER JOIN RolUsuario RU ON cru.rolUsuarioId_fk = RU.id
        INNER JOIN Rol R on RU.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SUN ON U.unidadOrgId_fk = SUN.id
        INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id

    WHERE 
        cru.bEliminado = 0 AND
        c.bEliminado = 0 AND
        -- (@ROL_USUARIO_ID IS NULL OR cru.rolUsuarioId_fk = @ROL_USUARIO_ID);
        cru.controlId_fk = @ROL_CONTROL_ID;
END
GO
