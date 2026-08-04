# AGENTS.md - scap-api-2

## Comandos

```
npm run dev          # Desarrollo con nodemon + tsx
npm run build        # Build de producción (tsx build.ts → tsc)
npm run lint         # ESLint sobre src/
npm run lint:fix     # ESLint --fix
npm run format       # Prettier --write src/
npm run test         # Tests con nodemon (Jasmine)
npm run test:no-reloading  # Tests sin reload
```

Orden de verificación: `npm run build` (incluye tsc y lint implícito).

## Arquitectura

- **ESM puro** (`"type": "module"` en package.json). Todos los imports deben usar extensión `.js` aunque el source sea `.ts`.
- **Alias de paths**: `@src/*` → `./src/*` (configurado en tsconfig.json).
- **Entrypoint**: `src/index.ts` → `src/pre-start.ts` (carga .env) → `src/server.ts` (Express).
- **Registro automático de rutas**: `src/routes/register.ts` escanea `src/modules/*/` y monta cada módulo que tenga `paths.ts` (export default con `Base: string`) y `router.ts` (export default Router).
- **Patrón de módulo**: `controller.ts` → `service.ts` → `repository.ts` → `repository.sql.ts`.
- **Selector de repo**: `selectRepo<T>()` en `src/util/repoSelector.ts` elige implementación según `DB_TYPE` del env.

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
