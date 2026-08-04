/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosById]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Obtener un horario por ID y cantidad de registros en HorarioDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
<<<<<<< Updated upstream
Create OR ALTER PROCEDURE [dbo].[usp_GetHorariosById] @HORARIOID INT
=======
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorariosById] @HORARIOID INT
>>>>>>> Stashed changes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT H.id
        , H.cTitulo AS titulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo
        , CASE 
            WHEN COUNT(DISTINCT HU.id) > 0
                OR COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
        , CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias
        -- , COUNT(DISTINCT HU.id) AS cantidadUsuarios
    FROM Horario H
    LEFT JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
            AND HD.bEliminado = 0
    LEFT JOIN HorarioUsuario HU
        ON HU.horarioId_fk = H.id
            AND HU.bEliminado = 0
    WHERE H.bEliminado = 0
        AND H.id = @HORARIOID
    GROUP BY H.id
        , H.cTitulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo;
END
GO
