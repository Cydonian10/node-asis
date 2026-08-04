import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type UsuarioRepo = typeof sqlRepo;

const repo = selectRepo<UsuarioRepo>({
  sql: sqlRepo,
});

export default repo;
