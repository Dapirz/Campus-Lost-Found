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
            ->with(['user', 'reportImages', 'claims:id,report_id,status'])
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
            ->with(['user', 'reportImages', 'claims.user'])
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

    /**
     * Setujui klaim barang temuan.
     */
    public function approveClaim(int $id): RedirectResponse
    {
        $claim = \App\Models\Claim::query()->with('report.user', 'user')->findOrFail($id);
        $report = $claim->report;

        if ($claim->status !== 'pending') {
            return redirect()
                ->route('admin.reports.show', $report->id)
                ->with('error', 'Only pending claims can be approved.');
        }

        DB::transaction(function () use ($claim, $report): void {
            // Generate 6-digit Claim Code
            $claimCode = 'LF-' . str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);

            // 1. Update status klaim & claim_code
            $claim->update([
                'status' => 'approved',
                'claim_code' => $claimCode,
            ]);

            // 2. Update status laporan ke 'collection_pending'
            $report->update([
                'status' => 'collection_pending',
            ]);

            // 3. Tolak klaim pending lainnya secara otomatis
            \App\Models\Claim::query()
                ->where('report_id', $report->id)
                ->where('id', '!=', $claim->id)
                ->where('status', 'pending')
                ->update(['status' => 'rejected']);

            // 4. Send database and Firebase notification to User B (Claimant)
            $claimantMsg = 'Your claim for "' . $report->title . '" has been approved! Please retrieve your item using claim code: ' . $claimCode;
            Notification::query()->create([
                'user_id' => $claim->user_id,
                'type' => 'claim_approved',
                'message' => $claimantMsg,
                'is_read' => false,
            ]);

            if ($claim->user && $claim->user->fcm_token) {
                $fcmService = app(\App\Services\FcmService::class);
                $fcmService->sendToToken(
                    $claim->user->fcm_token,
                    'Claim Approved',
                    $claimantMsg,
                    ['report_id' => (string) $report->id, 'type' => 'claim_approved', 'claim_code' => $claimCode]
                );
            }

            // 5. Send database and Firebase notification to User A (Reporter / Finder)
            // Include claimant's social media contact so reporter can contact the owner
            $reporterMsg = 'Your report "' . $report->title . '" has been approved for handover to its owner. Please coordinate the handover of the item.';
            if (!empty($claim->contact_social)) {
                $reporterMsg .= ' Owner contact: ' . $claim->contact_social;
            }
            Notification::query()->create([
                'user_id' => $report->user_id,
                'type' => 'handover_pending',
                'message' => $reporterMsg,
                'is_read' => false,
            ]);

            if ($report->user && $report->user->fcm_token) {
                $fcmService = app(\App\Services\FcmService::class);
                $fcmService->sendToToken(
                    $report->user->fcm_token,
                    'Handover Required',
                    $reporterMsg,
                    ['report_id' => (string) $report->id, 'type' => 'handover_pending']
                );
            }
        });

        return redirect()
            ->route('admin.reports.show', $report->id)
            ->with('success', 'Claim approved successfully.');
    }

    /**
     * Tolak klaim barang temuan.
     */
    public function rejectClaim(int $id): RedirectResponse
    {
        $claim = \App\Models\Claim::query()->with('report', 'user')->findOrFail($id);
        $report = $claim->report;

        if ($claim->status !== 'pending') {
            return redirect()
                ->route('admin.reports.show', $report->id)
                ->with('error', 'Only pending claims can be rejected.');
        }

        DB::transaction(function () use ($claim, $report): void {
            $claim->update([
                'status' => 'rejected',
            ]);

            // Your claim for "..." has been rejected because the proof of ownership is insufficient.
            $msg = 'Your claim for "' . $report->title . '" has been rejected because the proof of ownership is insufficient.';
            Notification::query()->create([
                'user_id' => $claim->user_id,
                'type' => 'claim_rejected',
                'message' => $msg,
                'is_read' => false,
            ]);

            if ($claim->user && $claim->user->fcm_token) {
                $fcmService = app(\App\Services\FcmService::class);
                $fcmService->sendToToken(
                    $claim->user->fcm_token,
                    'Claim Rejected',
                    $msg,
                    ['report_id' => (string) $report->id, 'type' => 'claim_rejected']
                );
            }
        });

        return redirect()
            ->route('admin.reports.show', $report->id)
            ->with('success', 'Claim rejected successfully.');
    }
}
