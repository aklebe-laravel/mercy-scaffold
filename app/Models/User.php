<?php

namespace App\Models;

use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;
use RuntimeException;

/**
 * @mixin IdeHelperUser
 */
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Prevent direct instantiation if a module has overridden the user model.
     *
     * @param  array<string, mixed>  $attributes
     *
     * @throws BindingResolutionException
     */
    public function __construct(array $attributes = [])
    {
        // Check if the container has a different binding registered
        if (static::class === self::class && app()->bound(self::class)) {
            $boundClass = app()->getProvider(self::class) ? app()->make(self::class) : null;

            if ($boundClass && get_class($boundClass) !== self::class) {
                throw new RuntimeException('Direct instantiation of App\Models\User is forbidden. Use app("user") instead.');
            }
        }

        parent::__construct($attributes);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime:Y-m-d H:i:s',
            'password'          => 'hashed',
        ];
    }

    /**
     * @return $this
     */
    public function makeWithDefaults(array $attributes): static
    {
        $this->setRawAttributes(array_merge([
            'name'              => Str::uuid()
                ->toString(),
            'email'             => Str::uuid()
                                       ->toString().'@local.test',
            'email_verified_at' => now(),
            'password'          => '1234567',
        ], $attributes));

        return $this;
    }

    /**
     * @return Builder
     */
    public static function getBuilderFrontendItems(): Builder
    {
        return self::query()
            ->frontendItems();
    }

    /**
     * scope frontendItems()
     *
     * @param  Builder  $query
     *
     * @return Builder
     */
    public function scopeFrontendItems(Builder $query): Builder
    {
        return $query;
    }

}