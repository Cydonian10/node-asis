// eslint.config.js
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import pluginN from 'eslint-plugin-n';
import eslintConfigPrettier from 'eslint-config-prettier';
import pluginPrettier from 'eslint-plugin-prettier';

export default tseslint.config(
  {
    ignores: ['dist', 'node_modules', 'coverage', 'spec/**/fixtures/**', '**/*.example.ts','eslint.config.js'],
  },
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ['**/*.ts'],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: ['./tsconfig.json'],
        tsconfigRootDir: import.meta.dirname,
        sourceType: 'module',
        ecmaVersion: 'latest',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint.plugin,
      n: pluginN,
      prettier: pluginPrettier,
    },
    rules: {
      'prettier/prettier': 'warn',
      '@typescript-eslint/explicit-member-accessibility': 'warn',
      '@typescript-eslint/no-misused-promises': 'off',
      '@typescript-eslint/no-floating-promises': 'off',
      'max-len': ['warn', { code: 80, ignorePattern: '^import\\s' }],
      '@typescript-eslint/no-unused-vars': [
        'warn',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_', caughtErrorsIgnorePattern: '^_' },
      ],
      'n/no-process-exit': 'off',
      'comma-dangle': ['warn', 'always-multiline'],
      'no-console': 1,
      'no-extra-boolean-cast': 0,
      semi: 1,
      quotes: ['warn', 'single'],
      'n/no-unsupported-features/es-syntax': ['error', { ignores: ['modules', 'dynamicImport'] }],
      'n/no-missing-import': 'off',
      'n/no-unpublished-import': 'off',
      'n/no-process-env': 'off',
    },
  },
  eslintConfigPrettier,
);
