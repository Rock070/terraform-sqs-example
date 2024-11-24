import { defineConfig } from 'vite';
import zipPack from "vite-plugin-zip-pack";

export default defineConfig({
  plugins: [
    zipPack({
      outFileName: 'lambda-sns.zip'
    })
  ],
  build: {
    lib: {
      entry: 'src/main.ts',
      formats: ['cjs'],
    }
  },
});
