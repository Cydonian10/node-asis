/** @type {import('jest').Config} */
const tsJestUnit = {
  tsconfig: 'tsconfig.json',
  diagnostics: {
    ignoreDiagnostics: [1343, 1378, 151002],
  },
};

const tsJestE2e = {
  tsconfig: 'tsconfig.json',
  useESM: true,
  diagnostics: false,
};

const moduleNameMapper = {
  '^@src/(.*)\\.js$': '<rootDir>/src/$1',
  '^@src/(.*)$': '<rootDir>/src/$1',
  '^(\\.{1,2}/.*)\\.js$': '$1',
};

const config = {
  projects: [
    {
      displayName: 'unit',
      testMatch: ['<rootDir>/src/**/*.test.ts', '<rootDir>/test/modules/**/*.test.ts'],
      transform: {
        '^.+\\.ts$': ['ts-jest', tsJestUnit],
      },
      moduleNameMapper,
      testEnvironment: 'node',
    },
    {
      displayName: 'e2e',
       testMatch: ['<rootDir>/test/e2e/**/*.e2e.test.ts'],
      transform: {
        '^.+\\.ts$': ['ts-jest', tsJestE2e],
      },
      extensionsToTreatAsEsm: ['.ts'],
      moduleNameMapper,
      testEnvironment: 'node',
      setupFiles: ['<rootDir>/test/setup.ts'],
    },
  ],
};

export default config;
