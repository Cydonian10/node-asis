IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetBiometricoWithDetalle'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetBiometricoWithDetalle]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricoWithDetalle]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de todos los biometricos con todos sus detalles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetBiometricoWithDetalle] @BIOMETRICOID INT
AS
BEGIN
    SELECT B.id
        , B.marca
        , B.tipoBD
        , DB.cNombre
        , DB.ip
        , DB.ubicacion
        , DB.serie
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , CASE 
            WHEN COUNT(DB.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
    FROM Biometrico AS B
    LEFT JOIN DetalleBiometrico AS DB
        ON DB.biometricoId_fk = B.id
            AND DB.bEliminado = 0
    WHERE B.id = @BIOMETRICOID
        AND B.bEliminado = 0
    GROUP BY B.id
        , B.marca
        , B.tipoBD
        , DB.biometricoId_fk
        , DB.cNombre
        , DB.ip
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , DB.serie;
END
GO


