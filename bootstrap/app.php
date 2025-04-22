<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Support\Facades\Log;

return Application::configure(basePath: dirname(__DIR__))
    ->booting(function (Application $app) {

        // // @deprecated: not needed since laravel v11 can configured .env file in ...
        // $envConfigFile = base_path('env-boot-config.php');
        // if (file_exists($envConfigFile)) {
        //     $envConfig = include $envConfigFile;
        //     if ($envFile = $envConfig['env_file'] ?? null) {
        //         $envFileFull = base_path($envFile);
        //         if (file_exists($envFileFull)) {
        //             // @todo: not working since laravel v11
        //             $app->loadEnvironmentFrom($envFile);
        //         }
        //
        //     } else {
        //         // die(__METHOD__.':'.$envFile);
        //     }
        // } else {
        //     // die("not found $envConfigFile");
        // }
        
    })
    ->booted(function (Application $app) {
        // all modules boot() was processed ...
    })
    ->withRouting(web: __DIR__.'/../routes/web.php', commands: __DIR__.'/../routes/console.php', health: '/up',)
    ->withMiddleware(function (Middleware $middleware) {
        // ...
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // ...
    })
    ->create();
