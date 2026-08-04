/*======================================================================================================
NOMBRE: 20260804-unidad-syncunidadid-unique
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Agregar constraint UNIQUE sobre Unidad.SyncUnidadId para bases existentes.
          El canon (database/tables/tablas.sql) ya define la columna como UNIQUE para
          instalaciones nuevas; este script cubre bases que ya existen.

NOTA: Si la BD real ya tiene unidades duplicadas por SyncUnidadId, la constraint fallara.
      Ejecutar una deduplicacion previa antes de aplicar este script.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
ALTER TABLE Unidad ADD CONSTRAINT UQ_Unidad_SyncUnidadId UNIQUE (SyncUnidadId);
GO
