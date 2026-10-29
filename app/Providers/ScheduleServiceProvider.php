<?php

namespace App\Providers;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
use Modules\SystemBase\app\Providers\Base\ScheduleBaseServiceProvider;
use Throwable;

class ScheduleServiceProvider extends ScheduleBaseServiceProvider
{
    protected function bootEnabledSchedule(Schedule $schedule): void
    {
        /**
         * Remove unused extra attributes
         */
        $schedule->call(function () {

            try {
                if ((Artisan::call('backup:run --only-db')) !== 0) {
                    Log::error("Backup failed in ".__METHOD__);
                }
            } catch (Throwable $exception) {
                Log::error("Backup command not found in ".__METHOD__);
            }

        })->dailyAt('03:00');

    }

}
