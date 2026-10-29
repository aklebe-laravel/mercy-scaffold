<?php
declare(strict_types = 1);

/**
 * Runs an artisan command from composer scripts, but only if the app can boot.
 *
 * In a fresh checkout the Mercy core modules (Modules/SystemBase, ...) are not cloned yet,
 * "./mercy install" does that. The app providers extend classes of these modules,
 * so artisan would fail and break "composer install". The install runs composer again later.
 *
 * Usage (composer.json): "@php bootstrap/artisan-if-ready.php package:discover --ansi"
 */

$root = dirname(__DIR__);

if (!is_dir($root.'/Modules/SystemBase')) {
    fwrite(STDERR, 'Mercy core modules are not installed yet, skipping "artisan '.implode(' ', array_slice($argv, 1)).'" (./mercy install runs it).'.PHP_EOL);
    exit(0);
}

$command = implode(' ', array_map('escapeshellarg', [PHP_BINARY, $root.'/artisan', ...array_slice($argv, 1)]));
passthru($command, $exitCode);
exit($exitCode);
