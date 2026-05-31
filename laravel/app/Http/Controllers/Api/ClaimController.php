<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Claim;
use App\Models\Report;
use App\Models\Notification;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ClaimController extends Controller
{
    /**
     * POST /api/reports/{id}/claim
     * Ajukan klaim barang baru.
     */
    public function store(Request $request, int $reportId): JsonResponse
    {
        $report = Report::query()->find($reportId);

        if (!$report) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan',
            ], 404);
        }

        // Pengaman: laporan harus berstatus verified agar bisa diklaim
        if ($report->status !== 'verified') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak atau laporan belum diverifikasi',
            ], 403);
        }

        // Pengaman: pelapor asli tidak boleh menge-claim laporannya sendiri
        if ($report->user_id === $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak bisa mengklaim laporan Anda sendiri',
            ], 403);
        }

        // Pengaman: pastikan user tidak mengajukan klaim ganda yang masih pending/approved
        $existingClaim = Claim::query()
            ->where('report_id', $reportId)
            ->where('user_id', $request->user()->id)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($existingClaim) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah mengajukan klaim untuk laporan ini',
            ], 400);
        }

        $validated = $request->validate([
            'proof_description' => ['required', 'string', 'min:10'],
            'proof_image'       => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
        ]);

        $claim = DB::transaction(function () use ($validated, $request, $report) {
            $proofImageUrl = null;

            // Upload gambar bukti jika ada
            if ($request->hasFile('proof_image')) {
                $path = $request->file('proof_image')->store('claims', 'public');
                $proofImageUrl = url('/storage/' . $path);
            }

            return Claim::query()->create([
                'report_id'         => $report->id,
                'user_id'           => $request->user()->id,
                'proof_description' => $validated['proof_description'],
                'proof_image_url'   => $proofImageUrl,
                'status'            => 'pending',
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan klaim berhasil dikirim, silakan tunggu verifikasi admin',
            'data'    => [
                'id'     => $claim->id,
                'status' => $claim->status,
            ],
        ], 201);
    }

    /**
     * PATCH /api/claims/{id}/confirm
     * Konfirmasi penerimaan barang secara fisik oleh pemilik (Self-Service).
     */
    public function confirm(Request $request, int $id): JsonResponse
    {
        $claim = Claim::query()->with('report.user')->find($id);

        if (!$claim) {
            return response()->json([
                'success' => false,
                'message' => 'Pengajuan klaim tidak ditemukan',
            ], 404);
        }

        // Pengaman: Hanya pengaju klaim asli yang bisa mengonfirmasi penerimaan barang
        if ($claim->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak',
            ], 403);
        }

        // Pengaman: Klaim harus berstatus approved (sedang proses serah terima)
        if ($claim->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Status klaim tidak valid untuk dikonfirmasi',
            ], 400);
        }

        DB::transaction(function () use ($claim) {
            // 1. Ubah status klaim ke 'received'
            $claim->update([
                'status' => 'received',
            ]);

            // 2. Ubah status laporan induk ke 'resolved'
            $claim->report->update([
                'status' => 'resolved',
            ]);

            // 3. Simpan notifikasi database untuk pelapor asli (User A)
            $message = 'Laporan "' . $claim->report->title . '" Anda telah berhasil diambil oleh pemiliknya yang sah.';
            Notification::query()->create([
                'user_id' => $claim->report->user_id,
                'type'    => 'claim_received',
                'message' => $message,
                'is_read' => false,
            ]);

            // 4. Kirim Push Notification Firebase (FCM) ke pelapor asli (User A)
            if ($claim->report->user && $claim->report->user->fcm_token) {
                $fcmService = app(FcmService::class);
                $fcmService->sendToToken(
                    $claim->report->user->fcm_token,
                    'Item Collected Successfully',
                    $message,
                    ['report_id' => (string) $claim->report->id, 'type' => 'claim_received']
                );
            }
        });

        return response()->json([
            'success' => true,
            'message' => 'Konfirmasi terima barang berhasil, laporan kini ditandai selesai',
        ]);
    }
}
