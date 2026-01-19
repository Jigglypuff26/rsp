import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      app: path.resolve(__dirname, './src/app'),
      entities: path.resolve(__dirname, './src/entities'),
      features: path.resolve(__dirname, './src/features'),
      pages: path.resolve(__dirname, './src/pages'),
      shared: path.resolve(__dirname, './src/shared'),
      widgets: path.resolve(__dirname, './src/widgets'),
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
