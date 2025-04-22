import {defineConfig} from 'vite';
import laravel from 'laravel-vite-plugin';

// todo: @import is deprecated, but @use is not working so far
// todo: "quietDeps: true" at least prevents a lot of extern deprecated warnings
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
        origin: 'http://localhost',
        cors: true,
    }
});