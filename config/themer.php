<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Themes Path
    |--------------------------------------------------------------------------
    |
    | The path where your themes are located. You can provide multiple paths
    | for theme discovery.
    |
    */
    'themes_path'     => base_path('themes'),

    /*
    |--------------------------------------------------------------------------
    | Active Theme
    |--------------------------------------------------------------------------
    |
    | The default active theme name.
    |
    */
    'active'          => (string) env('THEME_NAME', 'mercy-blank'),

    /*
    |--------------------------------------------------------------------------
    | Asset Configuration
    |--------------------------------------------------------------------------
    |
    | Configure how assets and Vite integration should behave.
    |
    */
    'assets'          => [
        'path'                => 'themes', // Public path suffix (public/themes)
        'publish_on_activate' => true,
        'symlink'             => (bool) env('THEMER_SYMLINK', true),
    ],

    /*
    |--------------------------------------------------------------------------
    | Discovery
    |--------------------------------------------------------------------------
    |
    | Configuration for theme discovery logic.
    |
    */
    'discovery'       => [
        'filename'     => 'theme.json',
        'scan_modules' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Theme Auto-Namespaces
    |--------------------------------------------------------------------------
    |
    | Automatically register view and Livewire namespaces for common theme
    | directories. These are applied to each theme during activation and
    | work alongside Livewire's native component_namespaces configuration.
    |
    */
    'auto_namespaces' => [
        'layouts'  => 'resources/views/layouts',
        'pages'    => 'resources/views/livewire/pages',
        // anonymous components like <x-theme-ui::pagination.item/>, child theme first, then its parents
        'theme-ui' => 'resources/views/components',
    ],

    'preview'   => [
        'enabled'              => (bool) env('THEMER_PREVIEW_ENABLED', false),
        'signed_urls'          => true,
        'ttl'                  => 2, // 60
        'allowed_environments' => ['local', 'staging'],
    ],

    /*
    |--------------------------------------------------------------------------
    | Default framework like 'tailwind', 'bootstrap', ...
    |--------------------------------------------------------------------------
    |
    | Take assets from themes/{$theme}/assets/{$framework}/...
    | Empty '' means no subfolder like themes/{$theme}/assets/...
    |
    */
    //'framework'    => env('THEME_FRAMEWORK', 'bootstrap'),
    'framework' => env('THEME_FRAMEWORK', ''), // nothing


];
