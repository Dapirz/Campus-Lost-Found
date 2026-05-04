<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * POST /api/notifications/fcm-token
     * Simpan FCM token perangkat Flutter ke server.
     */
    public function storeFcmToken(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fcm_token' => ['required', 'string'],
        ]);

        $request->user()->update([
            'fcm_token' => $validated['fcm_token'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token berhasil disimpan',
        ]);
    }

    /**
     * GET /api/notifications
     * Ambil daftar notifikasi untuk user yang login.
     */
    public function index(Request $request): JsonResponse
    {
        $notifications = Notification::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(function (Notification $notif) {
                return [
                    'id'         => $notif->id,
                    'type'       => $notif->type,
                    'message'    => $notif->message,
                    'is_read'    => $notif->is_read,
                    'created_at' => $notif->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $notifications,
        ]);
    }

    /**
     * PATCH /api/notifications/{id}/read
     * Tandai satu notifikasi sebagai sudah dibaca.
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $notification = Notification::query()
            ->where('user_id', $request->user()->id)
            ->where('id', $id)
            ->first();

        if (! $notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notifikasi tidak ditemukan',
            ], 404);
        }

        $notification->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sudah dibaca',
        ]);
    }
}
