<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\GoldPriceController;
use App\Http\Controllers\Api\PivotPointController;

Route::get('/gold-prices', [GoldPriceController::class, 'index']);
Route::get('/gold-prices/latest', [GoldPriceController::class, 'latest']);

Route::get('/pivot-point', [PivotPointController::class, 'index']);