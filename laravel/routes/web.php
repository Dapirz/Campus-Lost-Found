<?php

use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\AdminReportController;
use App\Http\Controllers\AdminUserController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Windows PHP server symlink workaround
Route::get('/storage/reports/{filename}', function (string $filename) {
    $path = storage_path('app/public/reports/' . $filename);
    if (!file_exists($path)) {
        abort(404);
    }
    return response()->file($path);
});

Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.submit');

    Route::middleware('admin.auth')->group(function () {
        Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');
        Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('admin.dashboard');
        Route::get('/reports', [AdminReportController::class, 'index'])->name('admin.reports.index');
        Route::get('/reports/{id}', [AdminReportController::class, 'show'])->name('admin.reports.show');
        Route::patch('/reports/{id}/verify', [AdminReportController::class, 'verify'])->name('admin.reports.verify');
        Route::patch('/reports/{id}/reject', [AdminReportController::class, 'reject'])->name('admin.reports.reject');
        Route::delete('/reports/{id}', [AdminReportController::class, 'destroy'])->name('admin.reports.destroy');

        // Admin Claims Approval / Rejection
        Route::patch('/claims/{id}/approve', [AdminReportController::class, 'approveClaim'])->name('admin.claims.approve');
        Route::patch('/claims/{id}/reject', [AdminReportController::class, 'rejectClaim'])->name('admin.claims.reject');
        Route::get('/users', [AdminUserController::class, 'index'])->name('admin.users.index');
        Route::patch('/users/{id}/toggle', [AdminUserController::class, 'toggle'])->name('admin.users.toggle');
        Route::delete('/users/{id}', [AdminUserController::class, 'destroy'])->name('admin.users.destroy');
    });
});
