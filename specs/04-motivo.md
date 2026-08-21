# SPEC 04 — Módulo Motivo con CRUD de catálogo

> **Status:** Aprobado
> **Depends on:** Ninguno
> **Date:** 2026-08-21
> **Objective:** Crear el módulo `motivo` para administrar el catálogo de motivos mediante un CRUD con validaciones estrictas, unicidad activa por nombre y eliminación lógica.

---

## Scope

**In:**

- Reutilizar la tabla existente `Motivo` en `database/tables/tablas.sql`.
- Exponer `GET /motivos` para listar únicamente motivos no eliminados.
- Exponer `GET /motivos/:id` para obtener un motivo activo por identificador.
- Exponer `POST /motivos` para crear motivos con `nombre`, `descripcion` y `documentoRequerido` opcional.
- Exponer `PUT /motivos/:id` para actualizar parcialmente `nombre`, `descripcion` y `documentoRequerido`.
- Rechazar cuerpos vacíos en la actualización.
- Exponer `DELETE /motivos/:id` para eliminar lógicamente un motivo, incluso si ya es referenciado por otros módulos.
- Exigir que `nombre` tenga entre 1 y 100 caracteres después de recortar espacios extremos.
- Permitir que `descripcion` sea opcional, nullable y tenga como máximo 255 caracteres.
- Usar `false` como valor predeterminado de `documentoRequerido` cuando se omita al crear.
- Impedir nombres duplicados entre motivos activos mediante una restricción de base de datos.
- Crear `src/modules/motivo/` siguiendo el patrón `controller.ts` → `service.ts` → `repository.ts` → `repository.sql.ts`.
- Crear DTOs de respuesta y DTOs de operación derivados de validaciones Zod estrictas.
- Documentar rutas y schemas con JSDoc `@swagger`.
- Crear procedimientos almacenados para listar, obtener, crear, actualizar y eliminar motivos.
- Propagar el usuario autenticado para `CreatedBy` y `UpdatedBy` usando los tipos definidos por la tabla existente.
- Agregar pruebas unitarias para validaciones y reglas del servicio.
- Mantener las convenciones actuales de respuestas HTTP y manejo de errores.

**Out of scope (for future specs):**

- Modificar los módulos `Permisos`, `Justificaciones` o `Licencia` para integrarlos con el nuevo catálogo.
- Cambiar las tablas o contratos de `Permisos`, `Justificaciones` o `Licencia`.
- Consultar motivos eliminados mediante endpoints públicos.
- Paginación, filtros avanzados u ordenamiento del listado.
- Pruebas E2E.
- Eliminación física de motivos.
- Integración con Kafka u otros sistemas externos.

---

## Data model

La tabla base ya existe en `database/tables/tablas.sql` y se reutiliza:

```sql
CREATE TABLE Motivo
(
    MotivoId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    DocumentoRequerido BIT DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
```

Se agrega un índice único filtrado para garantizar un solo motivo activo por nombre:

```sql
CREATE UNIQUE INDEX UX_Motivo_Active_Nombre
    ON Motivo (Nombre)
    WHERE Eliminado = 0;
```

Reglas del modelo:

- `MotivoId` es un identificador `INT IDENTITY(1,1)`.
- `Nombre` se almacena sin espacios extremos y debe tener entre 1 y 100 caracteres.
- `Descripcion` puede ser `NULL` y no puede superar 255 caracteres.
- `DocumentoRequerido` es booleano y vale `false` por defecto.
- `Eliminado = 1` representa eliminación lógica.
- Los listados y la consulta por ID solo devuelven registros con `Eliminado = 0`.
- La unicidad por nombre aplica solo a registros activos.

---

## Implementation plan

1. Actualizar `database/tables/tablas.sql` para agregar el índice único filtrado `UX_Motivo_Active_Nombre` sobre `Motivo.Nombre` con `Eliminado = 0`.
2. Crear `database/sql-scripts/procedures/MOTIVO/usp_GetMotivos.sql`, `usp_GetMotivoById.sql`, `usp_CreateMotivo.sql`, `usp_UpdateMotivo.sql` y `usp_DeleteMotivo.sql`.
3. Implementar en los procedimientos la exclusión de registros eliminados, la normalización del nombre, la actualización parcial y la traducción controlada de duplicados activos.
4. Crear `src/modules/motivo/dto/motivo.dto.ts` con el tipo de respuesta del catálogo.
5. Crear `src/modules/motivo/dto/crear-motivo.dto.ts` y `src/modules/motivo/dto/actualizar-motivo.dto.ts` derivados de sus schemas Zod.
6. Crear `src/modules/motivo/validations/crear-motivo.validation.ts` con `nombre` obligatorio, `descripcion` opcional y `documentoRequerido` opcional.
7. Crear `src/modules/motivo/validations/actualizar-motivo.validation.ts` con actualización parcial y rechazo de objetos vacíos.
8. Crear `src/modules/motivo/paths.ts` con `Base: '/motivos'` y documentación Swagger para las cinco operaciones CRUD.
9. Implementar `src/modules/motivo/router.ts`, `controller.ts`, `service.ts`, `repository.ts` y `repository.sql.ts`, usando `request.execute(...)` para invocar los procedimientos.
10. Registrar automáticamente el módulo mediante `paths.ts` y verificar que sus endpoints excluyan motivos eliminados.
11. Agregar pruebas unitarias para límites de nombre y descripción, defaults booleanos, payload parcial vacío, duplicados activos y eliminación lógica de motivos referenciados.
12. Ejecutar las pruebas unitarias y `npm run build` como verificación final.

---

## Acceptance criteria

- [x] `GET /motivos` devuelve todos los motivos no eliminados.
- [x] `GET /motivos/:id` devuelve un motivo activo existente.
- [x] `GET /motivos/:id` rechaza un identificador inexistente o eliminado usando las convenciones de error del proyecto.
- [x] `POST /motivos` exige un `nombre` de 1 a 100 caracteres después de aplicar trim.
- [x] `POST /motivos` acepta `descripcion` opcional de hasta 255 caracteres.
- [x] `POST /motivos` acepta `documentoRequerido` opcional y lo guarda como `false` cuando se omite.
- [x] `POST /motivos` rechaza nombres duplicados entre motivos activos.
- [x] `PUT /motivos/:id` actualiza parcialmente `nombre`, `descripcion` y `documentoRequerido`.
- [x] `PUT /motivos/:id` rechaza un body vacío.
- [x] `PUT /motivos/:id` aplica las mismas reglas de longitud, trim y unicidad del alta.
- [x] `DELETE /motivos/:id` marca el motivo como eliminado lógicamente.
- [x] Un motivo eliminado deja de aparecer en `GET /motivos` y no puede obtenerse por `GET /motivos/:id`.
- [x] Eliminar lógicamente un motivo referenciado por `Permisos`, `Justificaciones` o `Licencia` no rompe sus referencias históricas.
- [x] Después de eliminar lógicamente un motivo, otro motivo activo puede reutilizar su nombre.
- [x] Las rutas y schemas tienen documentación `@swagger` válida.
- [x] Los procedimientos se invocan desde `repository.sql.ts` mediante `request.execute(...)`.
- [x] Las pruebas unitarias cubren las validaciones y reglas del servicio indicadas.
- [x] `npm run build` pasa sin errores.

---

## Decisions

- **Yes:** Crear un CRUD completo con GET de listado, GET por ID, POST, PUT parcial y DELETE lógico. Proporciona la administración completa del catálogo solicitada.
- **Yes:** Usar `/motivos` como ruta base. Mantiene el recurso en plural y coincide con los módulos de catálogo existentes.
- **Yes:** Reutilizar la tabla `Motivo`. La estructura ya existe y ya es referenciada por otros dominios.
- **Yes:** Hacer `nombre` obligatorio, normalizado con trim y limitado a 100 caracteres. Evita registros vacíos o inconsistentes.
- **Yes:** Hacer `descripcion` opcional y limitarla a 255 caracteres. Respeta la columna existente sin obligar texto innecesario.
- **Yes:** Exponer `documentoRequerido` como booleano opcional con default `false`. Conserva el valor funcional de la tabla sin sobrecargar el alta.
- **Yes:** Aplicar unicidad solo entre nombres activos. Permite reutilizar el nombre después de una eliminación lógica.
- **Yes:** Eliminar lógicamente aunque existan referencias. Preserva el historial y evita romper claves foráneas.
- **Yes:** Mantener el catálogo aislado de `Permisos`, `Justificaciones` y `Licencia`. La integración de consumidores queda para otro spec.
- **Yes:** Usar actualización parcial y rechazar cuerpos vacíos. Mantiene el patrón de los módulos existentes y evita operaciones sin efecto.
- **Yes:** Agregar pruebas unitarias y ejecutar `npm run build`. El alcance no incluye pruebas E2E.
- **No:** Permitir consultas públicas de motivos eliminados. El contrato de catálogo expone solo registros activos.
- **No:** Eliminar físicamente registros. Puede afectar referencias históricas.
- **No:** Agregar paginación, filtros avanzados u ordenamiento. No son necesarios para este catálogo inicial.
- **No:** Modificar los módulos consumidores en esta especificación. Se evita ampliar el alcance funcional.

---

## Risks

| Risk                                                                        | Mitigation                                                                                        |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Dos solicitudes concurrentes crean el mismo nombre activo.                  | Mantener el índice único filtrado y convertir el error de constraint en una respuesta controlada. |
| Un nombre con espacios puede eludir validaciones o generar inconsistencias. | Aplicar trim antes de validar y persistir.                                                        |
| Un motivo eliminado podría seguir siendo usado por registros históricos.    | Usar eliminación lógica y conservar las claves foráneas existentes.                               |
| Un PUT vacío puede ocultar un error del cliente.                            | Rechazar objetos sin campos actualizables mediante un schema Zod estricto.                        |

---

## What is **not** in this spec

- Integración de `Motivo` con `Permisos`, `Justificaciones` o `Licencia`.
- Consulta o administración pública de motivos eliminados.
- Paginación, filtros avanzados u ordenamiento.
- Pruebas E2E.
- Eliminación física.
- Integración con Kafka u otros sistemas externos.

Cada elemento podrá definirse en su propio spec si se requiere.
