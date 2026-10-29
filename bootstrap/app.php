<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->booting(function (Application $app) {
        //
    })
    ->booted(function (Application $app) {
        // all modules boot() was processed ...
    })
    ->withRouting(web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        channels: __DIR__.'/../routes/channels.php',
        health: '/up')
    ->withExceptions(function (Exceptions $exceptions) {
        // ...
    })
    ->withMiddleware(function (Middleware $middleware) {
        // 1. Die Themer-Middleware an die 'web'-Gruppe anfügen
        $middleware->web(append: [
            \AlizHarb\Themer\Http\Middleware\PreviewTheme::class,
        ]);

        // 2. Bestehende Einstellungen (z.B. Trusted Proxies)
        $middleware->trustProxies(at: '*');
    })
    ->create();
