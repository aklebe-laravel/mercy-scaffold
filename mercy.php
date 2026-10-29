#!/usr/bin/env php
<?php
declare(strict_types = 1);

require __DIR__.'/vendor/autoload.php';

use AklebeLaravel\MercyPhpDeployment\MercyApp;

$dest = __DIR__;
new MercyApp($dest, $dest.'/resources/setup', $dest.'/storage/app/last-setup')
    // the project repository "project/" holds the configs (see README "Project")
    ->withProject($dest.'/project', [
        'dev'   => 'setup.yaml',
        'build' => 'setup-build.yaml',
    ])
    ->runDev();