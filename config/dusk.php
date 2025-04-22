<?php

use Illuminate\Support\Facades\Facade;

return [

    /*
    |--------------------------------------------------------------------------
    | Users
    |--------------------------------------------------------------------------
    |
    | Users to test with
    |
    */

    'users' => [
        'admin' => [
            'name' => env('DUSK_ADMIN_NAME', 'AdminTest1'),
            'password' => env('DUSK_ADMIN_PASSWORD', '1234567'),
        ],
        'trader1' => [
            'name' => env('DUSK_TRADER1_NAME', 'Trader1'),
            'password' => env('DUSK_TRADER1_PASSWORD', '1234567'),
        ],
        'trader2' => [
            'name' => env('DUSK_TRADER2_NAME', 'Trader2'),
            'password' => env('DUSK_TRADER2_PASSWORD', '1234567'),
        ],
    ],


];
