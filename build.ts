/**
 * Dynamic build.ts
 * - Limpia dist
 * - Copia src/common/templates
 * - Escanea src/modules//templates y los copia
 * - Ejecuta tsc
 */

import fs from 'fs-extra';
import { JetLogger } from 'jet-logger';
import childProcess from 'child_process';
import path from 'path';

const logger = new JetLogger();

(async () => {
  try {
    // 1. Limpia dist
    await remove('./dist/');

    // 2. Copia plantillas globales (common)
    const commonTemplates = './src/common/templates';
    if (await fs.pathExists(commonTemplates)) {
      await copy(commonTemplates, './dist/common/templates');
    }

    // 3. Copia plantillas dentro de cada feature
    const modulesDir = './src/modules';
    const features = await fs.readdir(modulesDir);
    for (const feat of features) {
      const tplSrc = path.join(modulesDir, feat, 'templates');
      const tplDest = path.join('./dist/modules', feat, 'templates');
      if (await fs.pathExists(tplSrc)) {
        await copy(tplSrc, tplDest);
        logger.info(`Copied templates for feature: ${feat}`);
      }
    }

    // 4. Transpila TS
    await exec('tsc --build tsconfig.prod.json', './');
  } catch (err) {
    logger.err(err as unknown);
    process.exit(1);
  }
})();

function remove(loc: string): Promise<void> {
  return new Promise((res, rej) =>
    fs.remove(loc, (err) => (err ? rej(err) : res())),
  );
}

function copy(src: string, dest: string): Promise<void> {
  return new Promise((res, rej) =>
    fs.copy(src, dest, (err) => (err ? rej(err) : res())),
  );
}

function exec(cmd: string, cwd: string): Promise<void> {
  return new Promise((res, rej) =>
    childProcess.exec(cmd, { cwd }, (err, stdout, stderr) => {
      if (stdout) logger.info(stdout);
      if (stderr) logger.warn(stderr);
      err ? rej(err) : res();
    }),
  );
}
