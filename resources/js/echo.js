// resources/js/echo.js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

// use window.laravelConfig prepared by blade
const config = window.laravelConfig?.reverb || {};

window.Echo = new Echo({
    broadcaster: 'reverb',
    key: config.key,
    wsHost: config.host || window.location.hostname,
    wsPort: config.port ?? 80,
    wssPort: config.port ?? 443,
    forceTLS: (config.scheme ?? 'https') === 'https',
    enabledTransports: ['ws', 'wss'],
});
