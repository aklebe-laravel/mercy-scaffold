#!/usr/bin/env php
<?php
declare(strict_types = 1);

require __DIR__.'/vendor/autoload.php';

use AklebeLaravel\MercyPhpDeployment\MercyApp;

$devSource = __DIR__;
$dest = __DIR__.'/storage/docker-builds/prod-build';
new MercyApp($dest, $devSource.'/resources/setup', $devSource.'/storage/app/last-setup')
    // the project repository "project/" holds the configs (see README "Project")
    ->withProject($devSource.'/project', [
        'dev'   => 'setup.yaml',
        'build' => 'setup-build.yaml',
    ])
    ->runDevBuildToProd();