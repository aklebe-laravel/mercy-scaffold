import {defineConfig} from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    css: {
        preprocessorOptions: {
            scss: {
                quietDeps: true
            }
        }
    },
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'Themes/aklebe_bs5/assets/css/app.css',
                'Themes/aklebe_bs5/assets/js/app.js'
            ],
            refresh: true,
        }),
    ],
    server: {
        hmr: {
            host: process.env.APP_DOMAIN,
            clientPort: 443, // NPM to 443
            protocol: 'wss', // Important for SSL
        },
        host: '0.0.0.0',
        watch: {
            usePolling: true,
        },
        port: process.env.VITE_PORT ? parseInt(process.env.VITE_PORT) : 5173,
        strictPort: true,
    }
});