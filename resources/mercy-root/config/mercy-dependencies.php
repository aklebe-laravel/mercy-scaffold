<?php

//// branch
//$defaultBranch = 'develop';
//$defaultBranchPrefix = 'dev-';
//// branch
//$defaultBranch = 'master';
//$defaultBranchPrefix = 'dev-';
// release
$defaultBranch = '^1.0';
$defaultBranchPrefix = '';

$composerBranch = $defaultBranchPrefix.$defaultBranch;

return [

    /*
    |--------------------------------------------------------------------------
    | GIT
    |--------------------------------------------------------------------------
    |
    | Used by console
    |
    */

    'default_branch'        => $defaultBranch,
    'default_branch_prefix' => $defaultBranchPrefix,
    'required' => [
        'git' => [
            'source'                => env('MODULE_DEPLOYENV_REQUIRE_MODULES_GIT'),
            'default_vendor'        => env('MODULE_DEPLOYENV_REQUIRE_MODULES_DEFAULT_VENDOR', 'aklebe-laravel'),
            // modules semantic version like '^1.0', 'dev-master' or '*'
            'modules'               => [
                'aklebe-laravel/system-base-module'      => $composerBranch,
                'aklebe-laravel/acl-module'              => $composerBranch,
                'aklebe-laravel/deploy-env-module'       => $composerBranch,
                'aklebe-laravel/form-module'             => $composerBranch,
                'aklebe-laravel/data-table-module'       => $composerBranch,
                'aklebe-laravel/telegram-api-module'     => $composerBranch,
                'aklebe-laravel/website-base-module'     => $composerBranch,
                //'aklebe-laravel/market-module'           => $composerBranch,
            ],
            'themes'                => [
                'aklebe-laravel/aklebe-bs5-theme'  => $composerBranch,
                //'aklebe-laravel/jumble-sale-theme' => $composerBranch,
            ],
        ],
    ],

];
