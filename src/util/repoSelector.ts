import EnvVars from '@src/constants/EnvVars.js';

const DB_TYPES = ['sql', 'postgres', 'mysql', 'mock'] as const;
type DbType = (typeof DB_TYPES)[number];

export function selectRepo<T>(impl: T): T;
export function selectRepo<T>(impls: Partial<Record<DbType, T>>): T;

export function selectRepo<T>(arg: T | Partial<Record<DbType, T>>): T {
  const type = String(EnvVars.Database.Type || 'sql').toLowerCase() as DbType;
  if (typeof arg !== 'object' || arg === null || Array.isArray(arg)) {
    return arg;
  }

  const impls = arg as Partial<Record<DbType, T>>;

  if (impls[type]) return impls[type] as T;

  if (impls.sql) return impls.sql as T;

  for (const key of DB_TYPES) {
    if (impls[key]) return impls[key] as T;
  }

  throw new Error(
    `No repository found. DB_TYPE=${type}. ` +
      `Provided: ${DB_TYPES.filter((k) => impls[k]).join(', ') || 'none'}`,
  );
}
