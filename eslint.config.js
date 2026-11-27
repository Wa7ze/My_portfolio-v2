import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist', 'legacy', 'node_modules', 'screenshots', '.lighthouse'] },
  {
    files: ['**/*.{ts,tsx}'],
    extends: [js.configs.recommended, ...tseslint.configs.strict, jsxA11y.flatConfigs.recommended],
    languageOptions: { ecmaVersion: 2022, globals: globals.browser },
    plugins: { 'react-hooks': reactHooks, 'react-refresh': reactRefresh },
    rules: {
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
    },
  },
  {
    // Context modules export a provider + its hook; entry points and scene modules export data.
    files: [
      'src/state/**',
      'src/story/useStoryProgress.tsx',
      'src/story/scenes/**',
      'src/components/ui/{Lightbox,NetButton}.tsx',
      'src/{main,notFound}.tsx',
    ],
    rules: { 'react-refresh/only-export-components': 'off' },
  },
  {
    files: ['scripts/**/*.mjs', '*.js'],
    extends: [js.configs.recommended],
    // Playwright page.evaluate() callbacks run in the browser.
    languageOptions: { globals: { ...globals.node, ...globals.browser } },
  },
  prettier,
);
