IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetBiometricos'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetBiometricos]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricos]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todos los biometricos activos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetBiometricos]
AS
BEGIN
    SELECT B.id
        , B.marca
        , B.tipoBD
        , CASE 
            WHEN COUNT(DB.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
    FROM Biometrico AS B
    LEFT JOIN DetalleBiometrico AS DB
        ON DB.biometricoId_fk = B.id
            AND DB.bEliminado = 0
    WHERE B.bEliminado = 0
    GROUP BY B.id
        , B.marca
        , B.tipoBD;
END
GO


