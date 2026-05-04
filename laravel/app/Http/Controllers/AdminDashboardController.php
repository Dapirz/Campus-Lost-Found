<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Report;
use App\Models\User;
use Illuminate\Contracts\View\View;

class AdminDashboardController extends Controller
{
    public function index(): View
    {
        return view('admin.dashboard.index', [
            'total_reports' => Report::query()->count(),
            'total_pending' => Report::query()->where('status', 'pending')->count(),
            'total_verified' => Report::query()->where('status', 'verified')->count(),
            'total_resolved' => Report::query()->where('status', 'resolved')->count(),
            'total_users' => User::query()->where('role', 'user')->count(),
            'total_lost' => Report::query()->where('type', 'lost')->count(),
            'total_found' => Report::query()->where('type', 'found')->count(),
            'total_rejected' => Notification::query()->where('type', 'report_rejected')->count(),
            'recent_reports' => Report::query()
                ->with(['user'])
                ->latest()
                ->take(5)
                ->get(),
        ]);
    }
}
