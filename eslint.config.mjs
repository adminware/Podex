import pluginJs from '@eslint/js';

export default [
	{
		languageOptions: {
			globals: {
				browser: true,
				es2021: true,
				webextensions: true,
				chrome: 'readonly',
				console: 'readonly',
				document: 'readonly',
				htmx: 'readonly',
				window: 'readonly',
			},
			parserOptions: {
				ecmaVersion: 12,
				sourceType: 'module',
			},
		},
		ignores: ['public/js/*', 'node_modules/*'],
		rules: {},
	},
	pluginJs.configs.recommended,
];
