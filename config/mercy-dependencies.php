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
                'aklebe-laravel/system-base-module'      => 'dev-master', // '*',
                'aklebe-laravel/acl-module'              => 'dev-master', // '*',
                'aklebe-laravel/deploy-env-module'       => 'dev-master', // '*',
                'aklebe-laravel/form-module'             => 'dev-master', // '*',
                'aklebe-laravel/data-table-module'       => 'dev-master', // '*',
                'aklebe-laravel/telegram-api-module'     => 'dev-master', // '*',
                'aklebe-laravel/website-base-module'     => 'dev-master', // '*',
                // 'aklebe-laravel/market-module'           => 'dev-master', // '*',
            ],
            'themes'         => [
                'aklebe-laravel/aklebe-bs5-theme'  => 'dev-master', // '*',
                // 'aklebe-laravel/jumble-sale-theme' => 'dev-master', // '*',
            ],
        ],
    ],


];
