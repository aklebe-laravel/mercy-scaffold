import {defineConfig} from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import {resolve} from 'node:path';

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
        // Vite watches the whole project root by default. vendor/ and storage/ alone are tens of thousands of files and
        // exhaust the inotify limit of the host (shared by all containers): ENOSPC "System limit for number of file
        // watchers reached". Blade views, modules and themes stay watched; storage/app/mercy-generated too (imported).
        watch: {
            ignored: [
                /\/vendor\//,
                /\/storage\/(?!app\/mercy-generated\/)/,
                /\/bootstrap\/cache\//,
                /\/public\/(build|storage|themes)\//,
                /\/\.(idea|junie|phpunit\.cache)\//,
            ],
        },
        host: '0.0.0.0',
        port: process.env.VITE_PORT ? parseInt(process.env.VITE_PORT) : 5173,
        strictPort: true,
    }
});