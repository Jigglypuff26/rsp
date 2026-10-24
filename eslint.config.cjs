const js = require('@eslint/js');
const globals = require('globals');
const tsParser = require('@typescript-eslint/parser');
const tsPlugin = require('@typescript-eslint/eslint-plugin');
const react = require('eslint-plugin-react');
const hooks = require('eslint-plugin-react-hooks');
const a11y = require('eslint-plugin-jsx-a11y');
const imports = require('eslint-plugin-import');
const prettier = require('eslint-config-prettier');
const prettierPlugin = require('eslint-plugin-prettier');

module.exports = [
  {
    ignores: [
      'node_modules/**',
      'build/**',
      'dist/**',
      'public/**',
      'coverage/**',
      '.nyc_output/**',
      '**/.*',
      '**/*.config.js',
      '**/*.config.ts',
      'eslint.config.cjs',
    ],
  },
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 'latest',
      sourceType: 'module',
      parserOptions: { project: './tsconfig.json', ecmaFeatures: { jsx: true } },
      globals: { ...globals.browser, ...globals.node, ...globals.vitest },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
      react,
      'react-hooks': hooks,
      'jsx-a11y': a11y,
      import: imports,
      prettier: prettierPlugin,
    },
    settings: {
      react: {
        version: 'detect',
      },
      'import/resolver': {
        typescript: {
          alwaysTryTypes: true,
          project: './tsconfig.json',
        },
        node: {
          extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'],
        },
      },
      'import/parsers': {
        '@typescript-eslint/parser': ['.ts', '.tsx'],
      },
    },
    rules: {
      ...js.configs.recommended.rules,
      ...tsPlugin.configs['eslint-recommended'].overrides[0].rules,
      ...tsPlugin.configs.recommended.rules,
      ...react.configs.recommended.rules,
      ...react.configs['jsx-runtime'].rules,
      ...hooks.configs.recommended.rules,
      ...a11y.configs.recommended.rules,
      ...imports.configs.recommended.rules,
      ...imports.configs.typescript.rules,
      ...prettier.rules,
      ...{
        'prettier/prettier': 'error',
        'react/react-in-jsx-scope': 'off',
        'react/jsx-uses-react': 'off',
        'react/jsx-props-no-spreading': 'off',
        'react/require-default-props': 'off',
        'react/function-component-definition': [
          'error',
          {
            namedComponents: 'arrow-function',
            unnamedComponents: 'arrow-function',
          },
        ],
        'import/prefer-default-export': 'off',
        'import/no-extraneous-dependencies': [
          'error',
          {
            devDependencies: [
              '**/*.test.ts',
              '**/*.test.tsx',
              '**/*.spec.ts',
              '**/*.spec.tsx',
              '**/setupTests.ts',
            ],
          },
        ],
        '@typescript-eslint/no-unused-vars': [
          'error',
          {
            argsIgnorePattern: '^_',
            varsIgnorePattern: '^_',
          },
        ],
        'no-console': [
          'warn',
          {
            allow: ['warn', 'error'],
          },
        ],
        'no-debugger': 'warn',
        'jsx-a11y/anchor-is-valid': [
          'error',
          {
            components: ['Link'],
            specialLink: ['to'],
          },
        ],
        'import/order': [
          'warn',
          {
            groups: [
              'builtin',
              'external',
              'internal',
              ['parent', 'sibling'],
              'index',
              'object',
              'type',
            ],
            pathGroups: [
              {
                pattern: 'react',
                group: 'external',
                position: 'before',
              },
              {
                pattern: 'react-dom',
                group: 'external',
                position: 'before',
              },
              {
                pattern: 'react-router-dom',
                group: 'external',
                position: 'before',
              },
              {
                pattern: 'app/**',
                group: 'internal',
                position: 'after',
              },
              {
                pattern: 'pages/**',
                group: 'internal',
                position: 'after',
              },
              {
                pattern: 'widgets/**',
                group: 'internal',
                position: 'after',
              },
              {
                pattern: 'features/**',
                group: 'internal',
                position: 'after',
              },
              {
                pattern: 'entities/**',
                group: 'internal',
                position: 'after',
              },
              {
                pattern: 'shared/**',
                group: 'internal',
                position: 'after',
              },
            ],
            pathGroupsExcludedImportTypes: ['react', 'react-dom'],
            'newlines-between': 'always',
            alphabetize: {
              order: 'asc',
              caseInsensitive: true,
            },
            warnOnUnassignedImports: true,
          },
        ],
      },
    },
  },
];
