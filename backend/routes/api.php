<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\GoldPriceController;
use App\Http\Controllers\Api\PivotPointController;
use Illuminate\Support\Facades\URL;
use App\Models\User;
use Illuminate\Auth\Events\Verified;

Route::get('/gold-prices', [GoldPriceController::class, 'index']);
Route::get('/gold-prices/latest', [GoldPriceController::class, 'latest']);

Route::get('/pivot-point', [PivotPointController::class, 'index']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
// Verifikasi email
Route::get('/email/verify/{id}/{hash}', function (Request $request, $id, $hash) {
    if (! URL::hasValidSignature($request)) {
        return response()->json([
            'success' => false,
            'message' => 'Link verifikasi tidak valid atau sudah kedaluwarsa.',
        ], 403);
    }

    $user = User::findOrFail($id);

    if (! hash_equals(sha1($user->getEmailForVerification()), $hash)) {
        return response()->json([
            'success' => false,
            'message' => 'Link verifikasi tidak cocok dengan email akun.',
        ], 403);
    }

    if (! $user->hasVerifiedEmail()) {
        $user->markEmailAsVerified();
        event(new Verified($user));
    }

    return response()->json([
        'success' => true,
        'message' => 'Email berhasil diverifikasi. Silakan login.',
    ]);
})->name('verification.verify');

Route::post(
    '/email/resend-verification',
    [AuthController::class, 'resendVerificationEmail']
)->middleware('throttle:6,1');