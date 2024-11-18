import { defineConfig } from 'vite';
import zipPack from "vite-plugin-zip-pack";

export default defineConfig({
  plugins: [
    zipPack({
      outFileName: 'lambda-sqs.zip'
    })
  ],
  build: {
    lib: {
      entry: 'src/main.ts',
      formats: ['cjs'],
    },
    rollupOptions: {
      external: ['@aws-sdk/client-sqs'],
    },
  },
});
