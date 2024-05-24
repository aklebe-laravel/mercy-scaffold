import {defineConfig} from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
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
});