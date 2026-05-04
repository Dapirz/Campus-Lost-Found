<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserProfileController extends Controller
{
    /**
     * GET /api/user/profile
     * Ambil data profil lengkap user yang login.
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data'    => [
                'id'            => $user->id,
                'name'          => $user->name,
                'email'         => $user->email,
                'total_reports' => $user->reports()->count(),
                'created_at'    => $user->created_at->format('Y-m-d'),
            ],
        ]);
    }

    /**
     * PUT /api/user/profile
     * Update nama atau password user.
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $rules = [
            'name' => ['nullable', 'string', 'max:255'],
        ];

        // Jika user ingin ganti password, semua field password wajib diisi
        if ($request->filled('password') || $request->filled('current_password')) {
            $rules['current_password']      = ['required', 'string'];
            $rules['password']              = ['required', 'string', 'min:8', 'confirmed'];
            $rules['password_confirmation'] = ['required', 'string'];
        }

        $validated = $request->validate($rules);

        // Update nama jika dikirim
        if (isset($validated['name'])) {
            $user->name = $validated['name'];
        }

        // Update password jika dikirim
        if (isset($validated['current_password'])) {
            if (! Hash::check($validated['current_password'], $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors'  => [
                        'current_password' => ['Password lama tidak sesuai'],
                    ],
                ], 422);
            }

            $user->password = $validated['password']; // auto-hashed via cast
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diupdate',
        ]);
    }
}
