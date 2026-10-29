<?php

return [

    /*
    |--------------------------------------------------------------------------
    |
    |--------------------------------------------------------------------------
    |
    |
    */

    'hosts' => [
        'app'     => env('APP_DOMAIN', ''),
        'reverb'  => env('REVERB_HOST', ''),
        'db'      => env('DB_HOST', ''),
        'default' => env('APP_PORT', ''),
    ],
    'ports' => [
        'app'               => env('APP_PORT', ''),
        'db'                => env('FORWARD_DB_PORT', ''),
        'redis'             => env('FORWARD_REDIS_PORT', ''),
        'mailpit'           => env('FORWARD_MAILPIT_PORT', ''),
        'mailpit_dashboard' => env('FORWARD_MAILPIT_DASHBOARD_PORT', ''),
        'reverb'            => env('REVERB_SERVER_PORT', ''),
        'vite'              => env('VITE_PORT', ''),
    ],

];
