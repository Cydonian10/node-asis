# AGENTS.md - scap-api-2

## Comandos

```
npm run dev          # Desarrollo con nodemon + tsx
npm run build        # Build de producción (tsx build.ts → tsc)
npm run lint         # ESLint sobre src/
npm run lint:fix     # ESLint --fix
npm run format       # Prettier --write src/
npm run test         # Tests unitarios con Jest
npm run test:e2e     # Tests E2E con Jest
npm run test:all     # Todos los tests
```

Orden de verificación: `npm run build` (incluye tsc y lint implícito).

## Arquitectura

- **ESM puro** (`"type": "module"` en package.json). Todos los imports deben usar extensión `.js` aunque el source sea `.ts`.
- **Alias de paths**: `@src/*` → `./src/*` (configurado en tsconfig.json).
- **Entrypoint**: `src/index.ts` → `src/pre-start.ts` (carga .env) → `src/server.ts` (Express).
- **Registro automático de rutas**: `src/routes/register.ts` escanea `src/modules/*/` y monta cada módulo que tenga `paths.ts` (export default con `Base: string`) y `router.ts` (export default Router).
- **Patrón de módulo**: `controller.ts` → `service.ts` → `repository.ts` → `repository.sql.ts`.
- **Selector de repo**: `selectRepo<T>()` en `src/util/repoSelector.ts` elige implementación según `DB_TYPE` del env.

## Estructura de un módulo

Cada módulo en `src/modules/<nombre>/` sigue esta estructura:

```
src/modules/usuario/
├── paths.ts           # Rutas + JSDoc @swagger. Export default { Base: '/ruta' }
├── router.ts          # Express Router, importa paths y controller
├── controller.ts      # Handlers de Express (req, res)
├── service.ts         # Lógica de negocio
├── repository.ts      # Interfaz de acceso a datos (selectRepo)
├── repository.sql.ts  # Implementación SQL de la interfaz
├── dto/               # Tipos (respuestas + z.infer desde validations)
│   ├── usuario.dto.ts                # Tipos de respuesta de la entidad (sin Zod)
│   ├── sync-usuario.dto.ts           # Tipos de respuesta de sync (sin Zod)
│   ├── actualizar-activo.dto.ts      # DTO de operación: z.infer del schema
│   └── migrar-syncUsuario.dto.ts     # DTO de operación: z.infer del schema
└── validations/      # Schemas Zod, un archivo por operación
    ├── actualizar-activo.validation.ts
    └── migrar-sync-usuario.validation.ts
```

Reglas de `dto/` y `validations/`:

- **`validations/`**: solo schemas Zod (`z.object(...).strict()`), un archivo por operación con el nombre `kebab-case.validation.ts` y su JSDoc `@swagger`.
- **`dto/`**: solo tipos. Los tipos de respuesta (lo que devuelve un SP) van en archivos `usuario.dto.ts` / `sync-usuario.dto.ts` sin Zod. Los DTOs de entrada por operación se derivan con `z.infer` importando el schema: `export type XDto = z.infer<typeof XSchema>;`.
- Nomenclatura: `validations/operacion.validation.ts` ↔ `dto/operacion.dto.ts`.

Ejemplo mínimo de `paths.ts`:
```ts
const ModuloPath = {
  Base: '/modulos',
  // @swagger ... documentación OpenAPI
  Delete: '/:id',
};
export default ModuloPath;
```

Ejemplo mínimo de `router.ts`:
```ts
import { Router } from 'express';
import ModuloPath from './paths.js';
import Controller from './controller.js';

const router = Router();
router.delete(ModuloPath.Delete, Controller.remove);
export default router;
```

## Convenciones

- **jet-logger v2**: No usar `import logger from 'jet-logger'`. Usar `import { JetLogger } from 'jet-logger'` e instanciar `new JetLogger()`. El wrapper del proyecto está en `src/common/logger.ts`.
- **tsconfig.prod.json** debe excluir `**/*.example.ts`, `spec`, `src/public/` y `build.ts` (el `extends` no hereda `exclude`).
- **Archivos `.example.ts`** son plantillas de referencia, NO se compilan ni se ejecutan.
- **Variables de entorno**: se cargan desde `env/{development|production|test}.env` en `pre-start.ts`. Declaradas con tipos en `src/constants/EnvVars.ts`.
- **Base de datos**: SQL Server (`mssql`). Los stored procedures se llaman con `request.execute('usp_Nombre')`.
- **Kafka**: integrado en `src/common/kafka/` pero actualmente deshabilitado (comentado en `index.ts`).
- **Swagger**: JSDoc con `@swagger` en `paths.ts` y DTOs. Setup en `src/swagger.ts`.

## Quirks

- `ts-node` NO funciona en este proyecto (ESM). Usar `tsx` para scripts TS.
- `__dirname`/`__filename` no existen en ESM; usar `fileURLToPath(import.meta.url)` (patrón ya usado en varios archivos).
- El build (`build.ts`) copia carpetas `templates/` de `src/common/` y `src/modules/*/templates/` a `dist/` antes de compilar.
- Docker expone puerto 3001 y usa `env/development.env`.
- Auth middleware solo activo en producción o cuando `SECURITY=on` en desarrollo.
- Tests usan Jest con `--experimental-vm-modules` (ESM). Config en `jest.config.js`.
