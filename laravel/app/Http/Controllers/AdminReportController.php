<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Report;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminReportController extends Controller
{
    public function index(Request $request): View
    {
        $reports = Report::query()
            ->with(['user', 'reportImages'])
            ->when($request->string('type')->value(), function ($query, string $type) {
                $query->where('type', $type);
            })
            ->when($request->string('status')->value(), function ($query, string $status) {
                $query->where('status', $status);
            })
            ->when($request->string('search')->trim()->value(), function ($query, string $search) {
                $query->where(function ($subQuery) use ($search): void {
                    $subQuery->where('title', 'like', '%'.$search.'%')
                        ->orWhere('description', 'like', '%'.$search.'%');
                });
            })
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.reports.index', [
            'reports' => $reports,
        ]);
    }

    public function show(int $id): View
    {
        $report = Report::query()
            ->with(['user', 'reportImages'])
            ->findOrFail($id);

        return view('admin.reports.show', [
            'report' => $report,
        ]);
    }

    public function destroy(int $id): RedirectResponse
    {
        $report = Report::query()
            ->with('reportImages')
            ->findOrFail($id);

        $this->deleteReportWithImages($report);

        return redirect()
            ->route('admin.reports.index')
            ->with('success', 'Report deleted successfully.');
    }

    public function verify(int $id): RedirectResponse
    {
        $report = Report::query()->findOrFail($id);

        if ($report->status !== 'pending') {
            return redirect()
                ->route('admin.reports.show', $report->id)
                ->with('error', 'Only reports with pending status can be verified.');
        }

        DB::transaction(function () use ($report): void {
            $report->update([
                'status' => 'verified',
            ]);

            $message = 'Your report "'.$report->title.'" has been verified and published.';

            Notification::query()->create([
                'user_id' => $report->user_id,
                'type' => 'report_verified',
                'message' => $message,
                'is_read' => false,
            ]);

            // Send Push Notification
            if ($report->user && $report->user->fcm_token) {
                $fcmService = app(\App\Services\FcmService::class);
                $fcmService->sendToToken(
                    $report->user->fcm_token,
                    'Report Verified',
                    $message,
                    ['report_id' => (string) $report->id, 'type' => 'report_verified']
                );
            }
        });

        return redirect()
            ->route('admin.reports.show', $report->id)
            ->with('success', 'Report verified successfully.');
    }

    public function reject(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'rejection_reason' => ['nullable', 'string', 'max:1000'],
        ]);

        $report = Report::query()->findOrFail($id);

        if ($report->status !== 'pending') {
            return redirect()
                ->route('admin.reports.show', $report->id)
                ->with('error', 'Only reports with pending status can be rejected.');
        }

        $reason = trim((string) ($validated['rejection_reason'] ?? ''));

        DB::transaction(function () use ($report, $reason): void {
            $report->update([
                'status' => 'rejected',
                'admin_notes' => $reason !== '' ? $reason : null,
            ]);

            $message = 'Your report "'.$report->title.'" has been rejected by the admin.';

            if ($reason !== '') {
                $message .= ' Rejection reason: '.$reason;
            }

            Notification::query()->create([
                'user_id' => $report->user_id,
                'type' => 'report_rejected',
                'message' => $message,
                'is_read' => false,
            ]);
            
            // Send Push Notification
            if ($report->user && $report->user->fcm_token) {
                $fcmService = app(\App\Services\FcmService::class);
                $fcmService->sendToToken(
                    $report->user->fcm_token,
                    'Report Rejected',
                    $message,
                    ['report_id' => (string) $report->id, 'type' => 'report_rejected']
                );
            }
        });

        return redirect()
            ->route('admin.reports.show', $report->id)
            ->with('success', 'Report rejected successfully.');
    }

    private function deleteReportWithImages(Report $report): void
    {
        foreach ($report->reportImages as $image) {
            $storagePath = $this->resolveStoragePath($image->image_url);

            if ($storagePath !== null && Storage::disk('public')->exists($storagePath)) {
                Storage::disk('public')->delete($storagePath);
            }
        }

        $report->delete();
    }

    private function resolveStoragePath(?string $imageUrl): ?string
    {
        if (blank($imageUrl)) {
            return null;
        }

        $path = parse_url($imageUrl, PHP_URL_PATH) ?: $imageUrl;
        $normalizedPath = str_replace('\\', '/', $path);

        if (Str::startsWith($normalizedPath, '/storage/')) {
            return ltrim(Str::after($normalizedPath, '/storage/'), '/');
        }

        if (Str::startsWith($normalizedPath, 'storage/')) {
            return ltrim(Str::after($normalizedPath, 'storage/'), '/');
        }

        if (Str::startsWith($normalizedPath, ['http://', 'https://', '/'])) {
            return null;
        }

        return ltrim($normalizedPath, '/');
    }
}
