import fs from 'fs';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import type { Router, RequestHandler } from 'express';
import logger from '@src/common/logger.js';

type PathsModule = { Base: string };
type RouterLike = RequestHandler;

// Define __dirname and __filename in ES module scope
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function resolveModulesDir(currentDir: string) {
  // dev: src/routes -> src/modules
  // prod: dist/routes -> dist/modules
  const trySrc = path.resolve(currentDir, '..', 'modules');
  const tryDist = path.resolve(currentDir, '..', '..', 'modules');
  return fs.existsSync(trySrc) ? trySrc : tryDist;
}

function getDefaultExport(mod: unknown): unknown {
  if (
    mod &&
    typeof mod === 'object' &&
    'default' in (mod as Record<string, unknown>)
  ) {
    return (mod as Record<string, unknown>).default;
  }
  return mod;
}
function isPathsModule(x: unknown): x is PathsModule {
  return (
    !!x && typeof x === 'object' && typeof (x as PathsModule).Base === 'string'
  );
}

function isRouterLike(x: unknown): x is RouterLike {
  return typeof x === 'function' && x != null && 'use' in (x as never);
}

function stringfyErr(e: unknown): string {
  if (e instanceof Error) return e.message;
  if (typeof e === 'string') return e;
  try {
    return JSON.stringify(e);
  } catch {
    return String(e);
  }
}

async function requireTsOrJsUnknown(
  absDir: string,
  fileBase: string,
): Promise<unknown> {
  const cands = [
    path.join(absDir, `${fileBase}.ts`), // ts-node dev
    path.join(absDir, `${fileBase}.js`), // build prod
    path.join(absDir, fileBase),
  ];

  let lastErr: unknown = null;

  for (const p of cands) {
    try {
      if (fs.existsSync(p)) {
        const fileUrl = pathToFileURL(p).href;
        const m = (await import(fileUrl)) as unknown;
        return getDefaultExport(m);
      }
    } catch (err) {
      lastErr = err;
    }
  }

  // Handle the case where the file is not found (fileBase without extension)
  const lastCandidate = path.join(absDir, fileBase);
  try {
    if (fs.existsSync(lastCandidate)) {
      const fileUrl = pathToFileURL(lastCandidate).href;
      const m = (await import(fileUrl)) as unknown;
      return getDefaultExport(m);
    }
  } catch (err) {
    lastErr = err;
  }

  if (lastErr) {
    logger.warn(
      `[routes] Se encontró "${fileBase}" en ${absDir} pero falló al cargar: ${stringfyErr(lastErr)}`,
    );
  }

  return null;
}

export async function registerRoutes(apiRouter: Router) {
  const modulesDir = resolveModulesDir(__dirname);
  const dirs = fs.readdirSync(modulesDir, { withFileTypes: true });

  for (const d of dirs) {
    if (!d.isDirectory()) continue;
    if (d.name.startsWith('_') || d.name === 'common') continue;

    const featureDir = path.join(modulesDir, d.name);
    const pathsMod = await requireTsOrJsUnknown(featureDir, 'paths');
    const routerMod = await requireTsOrJsUnknown(featureDir, 'router');

    if (!isPathsModule(pathsMod) || !isRouterLike(routerMod)) {
      logger.warn(
        `[routes] SKIP /${d.name}: falta paths.ts (Base) o router.ts`,
      );
      continue;
    }

    apiRouter.use(pathsMod.Base, routerMod);
    logger.info(`[routes] mounted ${d.name} at ${pathsMod.Base}`);
  }
}
