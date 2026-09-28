<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GoldPrice extends Model
{
    protected $fillable = [
        'commodity',
        'price',
        'open',
        'high',
        'low',
        'close',
        'recorded_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'open' => 'decimal:2',
        'high' => 'decimal:2',
        'low' => 'decimal:2',
        'close' => 'decimal:2',
        'recorded_at' => 'datetime',
    ];
}