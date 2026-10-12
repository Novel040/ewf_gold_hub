<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/reset-password', function (Request $request) {
    return view('auth.reset-password', [
        'email' => $request->query('email', ''),
        'token' => $request->query('token', ''),
    ]);
})->name('password.reset');