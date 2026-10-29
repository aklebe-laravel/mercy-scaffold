import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import { resolve } from 'node:path';

export default defineConfig({
    plugins: [
        tailwindcss({}),
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    resolve: {
        alias: {
            '@themes': resolve(__dirname, 'themes'),
            '@modules': resolve(__dirname, 'Modules'),
        },
    },
    server: {
        fs: {
            allow: [
                'resources',
                'node_modules',
                'themes',  // Important
                'Modules', // Important
                'storage/app/mercy-generated'
            ],
        },
        hmr: {
            host: process.env.APP_DOMAIN,
            clientPort: 443,
            protocol: 'wss',
            path: 'vite-hmr',
        },
        host: '0.0.0.0',
        port: process.env.VITE_PORT ? parseInt(process.env.VITE_PORT) : 5173,
        strictPort: true,
    }
});