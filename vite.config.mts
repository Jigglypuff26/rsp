import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const configDir = fileURLToPath(new URL('.', import.meta.url));

// https://vitejs.dev/config/
export default defineConfig({
  base: './', // Относительные пути для билда
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(configDir, './src'),
      app: path.resolve(configDir, './src/app'),
      entities: path.resolve(configDir, './src/entities'),
      features: path.resolve(configDir, './src/features'),
      pages: path.resolve(configDir, './src/pages'),
      shared: path.resolve(configDir, './src/shared'),
      widgets: path.resolve(configDir, './src/widgets'),
    },
  },
  server: {
    port: 3000,
    host: true, // Прослушивание на всех интерфейсах (необходимо для Docker)
    open: true,
    strictPort: false,
    // Разрешаем доступ с любых хостов в dev режиме
    allowedHosts: [
      'localhost',
      '.pp-maksim.ru', // Поддержка всех поддоменов
      '.local',
    ],
    watch: {
      usePolling: true, // Необходимо для Docker в некоторых системах
    },
  },
  build: {
    outDir: 'build',
    sourcemap: true,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/setupTests.ts',
    css: true,
  },
});
