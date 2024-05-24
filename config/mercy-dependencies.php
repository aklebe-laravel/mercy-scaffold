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
            'default_vendor' => env('MODULE_DEPLOYENV_REQUIRE_MODULES_DEFAULT_VENDOR', 'AKlebeLaravel'),
            'modules'        => [
                'AKlebeLaravel/system-base-module'      => 'dev-master', // '*',
                'AKlebeLaravel/acl-module'              => 'dev-master', // '*',
                'AKlebeLaravel/deploy-env-module'       => 'dev-master', // '*',
                'AKlebeLaravel/form-module'             => 'dev-master', // '*',
                'AKlebeLaravel/data-table-module'       => 'dev-master', // '*',
                'AKlebeLaravel/telegram-api-module'     => 'dev-master', // '*',
                'AKlebeLaravel/website-base-module'     => 'dev-master', // '*',
                // 'AKlebeLaravel/market-module'           => 'dev-master', // '*',
            ],
            'themes'         => [
                'AKlebeLaravel/aklebe-bs5-theme'  => 'dev-master', // '*',
                // 'AKlebeLaravel/jumble-sale-theme' => 'dev-master', // '*',
            ],
        ],
    ],


];
