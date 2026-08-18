# SPEC 01 — Módulo Biometrico y Marca Biometrico con CRUD completo

> **Status:** Implementado
> **Depends on:** Ninguno
> **Date:** 2026-08-18
> **Objective:** Crear dos módulos CRUD completos (`biometrico` y `marca-biometrico`) con validaciones Zod, DTOs, documentación Swagger, procedimientos almacenados SQL y corrección del esquema de tablas existente.

---

## Scope

**In:**

- Corregir `database/tables/tablas.sql` para agregar comas faltantes entre `Tarjeta`, `Huella` y `Rostro` en `Biometrico`, y garantizar que `MarcaBiometrico.Nombre` tenga `UNIQUE`.
- Crear módulo `src/modules/marca-biometrico/` con CRUD: `POST /`, `GET /`, `GET /:id`, `PUT /:id`, `DELETE /:id` montado en `/marca-biometrico`.
- Crear módulo `src/modules/biometrico/` con CRUD: `POST /`, `GET /`, `GET /:id`, `PUT /:id`, `DELETE /:id` montado en `/biometrico`.
- Validaciones Zod estrictas (`z.object(...).strict()`) para cada operación de entrada.
- DTOs derivados con `z.infer` para operaciones de entrada y tipos de respuesta separados en `dto/`.
- Documentación Swagger JSDoc en `paths.ts` y DTOs.
- Procedimientos almacenados SQL independientes por operación: `usp_CreateMarcaBiometrico`, `usp_GetMarcaBiometricos`, `usp_GetMarcaBiometricoById`, `usp_UpdateMarcaBiometrico`, `usp_DeleteMarcaBiometrico` y equivalentes para `Biometrico`.
- Eliminación lógica (`Eliminado = 1`) para ambas entidades.
- FK obligatoria: `Biometrico.MarcaBiometricoId → MarcaBiometrico.MarcaBiometricoId`.
- Unicidad en `MarcaBiometrico.Nombre`.
- Auditoría (`CreatedBy`, `UpdatedBy`) tomando el usuario autenticado del request.
- Listados excluyen registros con `Eliminado = 1`.
- Pruebas unitarias para validaciones y servicio, y pruebas E2E para endpoints.
- Verificación final: `npm run build` debe pasar sin errores.

**Out of scope (for future specs):**

- Conexión o comunicación con dispositivos biométricos reales.
- Gestión de credenciales, tokens o autenticación específica para dispositivos.
- Paginación, filtros avanzados u ordenamiento en listados.
- Migración de datos existentes.
- Integración con Kafka u otros sistemas de mensajería.
- Creación de seeds específicos para estas tablas.

---

## Data model

```sql
-- Corregir en database/tables/tablas.sql

CREATE TABLE MarcaBiometrico
(
    MarcaBiometricoId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(30) NOT NULL,
    TipoDB VARCHAR(20) NOT NULL,
    Detalle VARCHAR(50) NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_MarcaBiometrico_Nombre UNIQUE (Nombre)
);

CREATE TABLE Biometrico
(
    BiometricoId INT IDENTITY(1,1) PRIMARY KEY,
    MarcaBiometricoId INT NOT NULL,
    Nombre VARCHAR(40) NOT NULL,
    Ip VARCHAR(20) NOT NULL,
    Serie VARCHAR(20) NOT NULL,
    Ubicacion VARCHAR(50) NOT NULL,
    Tarjeta BIT NOT NULL,
    Huella BIT NOT NULL,
    Rostro BIT NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MarcaBiometricoId) REFERENCES MarcaBiometrico(MarcaBiometricoId)
);
```

**Conventions:**

- PK: `INT IDENTITY(1,1)` secuencial.
- Auditoría: `CreatedBy` y `UpdatedBy` como `INT` (id del usuario autenticado).
- Soft-delete: columna `Eliminado BIT DEFAULT 0`.
- Unicidad: `MarcaBiometrico.Nombre` con `UNIQUE`.
- FK: `Biometrico.MarcaBiometricoId` es `NOT NULL`.

---

## Implementation plan

1. Corregir `database/tables/tablas.sql`: agregar comas entre `Tarjeta`, `Huella` y `Rostro` en `Biometrico`, y agregar `UNIQUE` a `MarcaBiometrico.Nombre`.
2. Crear `database/sql-scripts/procedures/MARCA_BIOMETRICO/` con 5 procedimientos: `usp_CreateMarcaBiometrico`, `usp_GetMarcaBiometricos`, `usp_GetMarcaBiometricoById`, `usp_UpdateMarcaBiometrico`, `usp_DeleteMarcaBiometrico`.
3. Crear `database/sql-scripts/procedures/BIOMETRICO/` con 5 procedimientos: `usp_CreateBiometrico`, `usp_GetBiometricos`, `usp_GetBiometricoById`, `usp_UpdateBiometrico`, `usp_DeleteBiometrico`.
4. Crear módulo `src/modules/marca-biometrico/` con `paths.ts`, `router.ts`, `controller.ts`, `service.ts`, `repository.ts`, `repository.sql.ts`, carpeta `dto/` y carpeta `validations/`.
5. Crear módulo `src/modules/biometrico/` con la misma estructura que `marca-biometrico`.
6. Agregar validaciones Zod estrictas para cada operación de entrada (crear y actualizar) en cada módulo.
7. Agregar DTOs derivados con `z.infer` para operaciones de entrada y tipos de respuesta en `dto/`.
8. Agregar documentación Swagger JSDoc en `paths.ts` de cada módulo.
9. Ejecutar `npm run build` para verificar que todo compila sin errores.
10. Agregar pruebas unitarias para validaciones y servicio de ambos módulos.
11. Agregar pruebas E2E para endpoints de ambos módulos.

---

## Acceptance criteria

- [x] `database/tables/tablas.sql` corrige las comas entre `Tarjeta`, `Huella` y `Rostro` en `Biometrico`.
- [x] `MarcaBiometrico.Nombre` tiene restricción `UNIQUE`.
- [x] Procedimientos SQL creados en carpetas separadas por entidad.
- [x] Módulo `marca-biometrico` expone rutas `POST /`, `GET /`, `GET /:id`, `PUT /:id`, `DELETE /:id` en `/marca-biometrico`.
- [x] Módulo `biometrico` expone rutas `POST /`, `GET /`, `GET /:id`, `PUT /:id`, `DELETE /:id` en `/biometrico`.
- [x] Validaciones Zod usan `z.object(...).strict()` para cada operación.
- [x] DTOs de operación derivan de schemas con `z.infer`.
- [x] DTOs de respuesta son tipos sin Zod en archivos separados.
- [x] `paths.ts` documenta cada endpoint con JSDoc `@swagger`.
- [x] DELETE es lógico (`Eliminado = 1`) en ambas entidades.
- [x] GET de listado excluye registros con `Eliminado = 1`.
- [x] Auditoría toma el usuario autenticado del request.
- [x] FK de `Biometrico.MarcaBiometricoId` es obligatoria y valida existencia de marca.
- [x] Pruebas unitarias pasan.
- [x] Pruebas E2E pasan.
- [x] `npm run build` pasa sin errores.

---

## Decisions

- **Yes:** Eliminación lógica (`Eliminado`) para ambas entidades. Más seguro para datos biométricos y auditoría.
- **Yes:** FK obligatoria de `Biometrico` hacia `MarcaBiometrico`. Cada biométrico debe pertenecer a una marca.
- **Yes:** Unicidad de `MarcaBiometrico.Nombre`. Evita marcas duplicadas y simplifica validación.
- **Yes:** Procedimientos SQL independientes por operación. Facilita mantenimiento y despliegue.
- **Yes:** Auditoría con usuario autenticado del request. Consistente con la convención del proyecto.
- **Yes:** Rutas REST estándar (`POST /`, `GET /`, `GET /:id`, `PUT /:id`, `DELETE /:id`). Consistente con módulos existentes.
- **No:** Paginación o filtros avanzados. Se puede agregar en un spec futuro si se requiere.
- **No:** Comunicación con dispositivos biométricos reales. Fuera de alcance de esta especificación.
- **No:** Migración de datos existentes. Las tablas ya existen; solo se corrigen y se agregan SPs.

---

## Risks

| Risk                                      | Mitigation                                                     |
| ----------------------------------------- | -------------------------------------------------------------- |
| `tablas.sql` corrupto por comas faltantes | Corregir en paso 1 del plan antes de cualquier otro cambio     |
| SP falla al validar FK inexistente        | Validar en SP que `MarcaBiometricoId` exista antes de insertar |
| Nombre duplicado en `MarcaBiometrico`     | SP valida unicidad y retorna error claro si falla              |

---

## What is **not** in this spec

- Conexión con dispositivos biométricos reales.
- Gestión de credenciales o autenticación específica para dispositivos.
- Paginación, filtros avanzados u ordenamiento en listados.
- Migración de datos existentes.
- Integración con Kafka u otros sistemas de mensajería.
- Creación de seeds específicos para estas tablas.

Cada uno de estos, si se necesita, va en su propio spec.
