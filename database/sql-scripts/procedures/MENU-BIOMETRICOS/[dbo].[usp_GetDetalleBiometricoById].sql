IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetDetalleBiometricoById'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetDetalleBiometricoById]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleBiometricoById]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los biometricos, por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetDetalleBiometricoById] @DETALLEID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT DB.id
        , DB.cNombre
        , DB.ip
        , DB.serie
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , B.marca
        , B.tipoBD
        , CASE 
            WHEN COUNT(DISTINCT AR.id) > 0
                OR COUNT(DISTINCT AM.id) > 0
                OR COUNT(DISTINCT AE.id) > 0
                THEN 1
            ELSE 0
            END AS EnUso
    FROM DetalleBiometrico AS DB
    INNER JOIN Biometrico AS B
        ON B.id = DB.biometricoId_fk
    LEFT JOIN AsistenciaRegular AR
        ON AR.detalleBiometricoId_fk = DB.id
            AND AR.bEliminado = 0
    LEFT JOIN AsistenciaModificada AM
        ON AM.detalleBiometricoId_fk = DB.id
            AND AM.bEliminado = 0
    LEFT JOIN AsistenciaExtendida AE
        ON AE.detalleBiometricoId_fk = DB.id
            AND AE.bEliminado = 0
    WHERE DB.id = @DETALLEID
        AND b.bEliminado = 0
        AND DB.bEliminado = 0
    GROUP BY DB.id
        , DB.cNombre
        , DB.ip
        , DB.serie
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , B.marca
        , B.tipoBD;
END
GO


