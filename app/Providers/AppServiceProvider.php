<?php

declare(strict_types = 1);

namespace App\Providers;

use Exception;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Vite;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\View;
use Livewire\Livewire;
use Modules\SystemBase\app\Providers\Base\BaseServiceProvider;
use Modules\SystemBase\app\Services\ModuleService;
use Nwidart\Modules\Module;

class AppServiceProvider extends BaseServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register(): void
    {
        // Before all modules boo() called ...
        $this->app->booting(function () {
            // ...
        });

        // After all modules boot() called ...
        $this->app->booted(function () {
            // merge for all modules in 'config/combined-module-xxx.php'
            $this->mergeCombinedConfigs();
        });

        $this->app->register(ScheduleServiceProvider::class);
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot(): void
    {
        $this->insideOutsideDockerModifications();

        // Prevent silent lazy loading globally
        Model::preventLazyLoading(!app()->isProduction());

        Carbon::setLocale(config('app.locale'));

        if (config('app.force_https', false)) { // Default value should be false for local server
            URL::forceScheme('https');
        }

        // Theme-Fallback for views (layouts.master)
        $activeTheme = config('themer.active', 'default');
        $themeViewsPath = base_path("themes/{$activeTheme}/resources/views");

        if (is_dir($themeViewsPath)) {
            View::addLocation($themeViewsPath);
            $componentsPath = $themeViewsPath.'/components';
            if (is_dir($componentsPath)) {
                Blade::anonymousComponentPath($componentsPath, 'theme-ui');
            }
        }

        // @vite-Direktive without themer
        $this->app->singleton(Vite::class, function ($app) {
            return new Vite();
        });

        // register livewire for all enabled nwidart modules
        $this->app->booted(function () {

            $enabledModules = ModuleService::getOrderedEnabledModules();
            foreach ($enabledModules as $module) {
                $lowerName = $module->getKebabName();     // like. "website-base" or "my-module"
                $studlyName = $module->getStudlyName();   // like "WebsiteBase" or "MyModule"

                $classPath = $module->getPath().'/app/Http/Livewire';
                $viewPath = $module->getPath().'/resources/views';
                if (is_dir($classPath) && is_dir($viewPath)) {
                    Livewire::addNamespace(namespace: $lowerName,
                        viewPath: $viewPath,
                        classNamespace: "Modules\\{$studlyName}\\app\\Http\\Livewire");
                }
            }
        });


    }

    /**
     * @return void
     */
    private function insideOutsideDockerModifications(): void
    {
        $scheme = 'http://';
        $hostDev = 'localhost';
        $hostBox = 'host.docker.internal';

        // 2. Separate port and path strictly
        $apiPort = ':81';
        $apiPath = '/api';

        // 3. Assemble local comparison string safely
        $localCheck = $scheme.$hostDev.$apiPort.$apiPath;

        if (config('services.npm.url') === $localCheck && $this->isRunningInsideDocker()) {
            // 4. Assemble the real gateway target string with port 81 included
            $dockerGatewayUrl = $scheme.$hostBox.$apiPort.$apiPath;

            config(['services.npm.url' => $dockerGatewayUrl]);
        }

    }

    /**
     * Merge config per module or all in one ...
     *
     * @return void
     */
    public function mergeCombinedConfigs(): void
    {
        // get all merged enabled module configs named 'combined-module-my-module-xyz.php'
        ModuleService::runOrderedEnabledModules(function (?Module $module) {
            if (!$module) {
                return true;
            }
            try {
                $moduleFoundSnakeName = ModuleService::getModelSnakeName($module->getName());
                $moduleFoundKey = $this->getCombinedModuleConfigKey($moduleFoundSnakeName);
                $configPath = 'config/'.$moduleFoundKey.'.php';
                $configFullPath = base_path($configPath);

                if (file_exists($configFullPath)) {
                    $this->mergeConfigFromRecursive($configFullPath, $moduleFoundKey);
                }
            } catch (Exception) {
                // file not found, ignore it ...
            }

            return true;
        });
    }

    /**
     * Detects if the current environment is running inside a Docker container.
     */
    private function isRunningInsideDocker(): bool
    {
        return file_exists('/.dockerenv')
               || (file_exists('/proc/1/cgroup') && str_contains(file_get_contents('/proc/1/cgroup'), 'docker'));
    }

}
