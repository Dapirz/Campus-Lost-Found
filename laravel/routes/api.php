<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\UserProfileController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Semua route di file ini otomatis mendapat prefix /api.
| Public routes tidak memerlukan token.
| Protected routes memerlukan Sanctum Bearer token.
|
*/

// ============================================================
// PUBLIC ROUTES (tidak perlu token)
// ============================================================

// Auth
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Reports (public — verified only)
Route::get('/reports', [ReportController::class, 'index']);
Route::get('/reports/{id}', [ReportController::class, 'show'])->where('id', '[0-9]+');

// ============================================================
// PROTECTED ROUTES (butuh Sanctum Bearer token)
// ============================================================

Route::middleware(['auth:sanctum', 'api.active'])->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Reports — /reports/my must be before /reports/{id}
    Route::get('/reports/my', [ReportController::class, 'my']);
    Route::post('/reports', [ReportController::class, 'store']);
    Route::delete('/reports/{id}', [ReportController::class, 'destroy']);
    Route::patch('/reports/{id}/resolve', [ReportController::class, 'resolve']);

    // User Profile
    Route::get('/user/profile', [UserProfileController::class, 'show']);
    Route::put('/user/profile', [UserProfileController::class, 'update']);

    // Notifications
    Route::post('/notifications/fcm-token', [NotificationController::class, 'storeFcmToken']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
});
