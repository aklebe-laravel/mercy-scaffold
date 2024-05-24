<?php

namespace App\Providers;

use Illuminate\Foundation\AliasLoader;
use Illuminate\Support\Facades\URL;
use Intervention\Image\Facades\Image;
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
    public function register()
    {
        // Aliases ...
        $loader = AliasLoader::getInstance();
        $loader->alias('Image', Image::class);

        // Before all modules boo() called ...
        $this->app->booting(function(){
            // ...
        });

        // After all modules boot() called ...
        $this->app->booted(function(){
            // merge for all modules in 'config/combined-module-xxx.php'
            $this->mergeCombinedConfigs();
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        if (env('FORCE_HTTPS', false)) { // Default value should be false for local server
            URL::forceScheme('https');
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
            try {
                $moduleFoundSnakeName = ModuleService::getModelSnakeName($module);
                $moduleFoundKey = $this->getCombinedModuleConfigKey($moduleFoundSnakeName);
                $configPath = 'config/'.$moduleFoundKey.'.php';
                $configFullPath = base_path($configPath);

                if (file_exists($configFullPath)) {
                    $this->mergeConfigFromRecursive($configFullPath, $moduleFoundKey);
                }
            } catch (\Exception) {
                // file not found, ignore it ...
            }
            return true;
        });

    }

}
