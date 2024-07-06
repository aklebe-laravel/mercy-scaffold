<?php

return [

    /*
    |--------------------------------------------------------------------------
    | GIT
    |--------------------------------------------------------------------------
    |
    | Used by console
    |
    */

    'required' => [
        'git' => [
            'source'         => env('MODULE_DEPLOYENV_REQUIRE_MODULES_GIT'),
            'default_vendor' => env('MODULE_DEPLOYENV_REQUIRE_MODULES_DEFAULT_VENDOR', 'aklebe-laravel'),
            'modules'        => [
                'aklebe-laravel/system-base-module'      => '^1.0',
                'aklebe-laravel/acl-module'              => '^1.0',
                'aklebe-laravel/deploy-env-module'       => '^1.0',
                'aklebe-laravel/form-module'             => '^1.0',
                'aklebe-laravel/data-table-module'       => '^1.0',
                'aklebe-laravel/telegram-api-module'     => '^1.0',
                'aklebe-laravel/website-base-module'     => '^1.0',
                // 'aklebe-laravel/market-module'           => '^1.0',
            ],
            'themes'         => [
                'aklebe-laravel/aklebe-bs5-theme'  => '^1.0',
                // 'aklebe-laravel/jumble-sale-theme' => '^1.0',
            ],
        ],
    ],


];
