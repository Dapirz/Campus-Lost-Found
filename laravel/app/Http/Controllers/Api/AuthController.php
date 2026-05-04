<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * POST /api/auth/register
     * Registrasi akun mahasiswa baru.
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = User::query()->create([
            'name'     => $validated['name'],
            'email'    => $validated['email'],
            'password' => $validated['password'], // auto-hashed via cast
            'role'     => 'user',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data'    => [
                'user' => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                ],
            ],
        ], 201);
    }

    /**
     * POST /api/auth/login
     * Login mahasiswa — mengembalikan Sanctum token.
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kredensial tidak valid',
            ], 401);
        }

        // Cek apakah akun dinonaktifkan (deactivated)
        if (! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda telah dinonaktifkan oleh Admin. Hubungi dukungan untuk informasi lebih lanjut.',
            ], 403);
        }

        // Hanya user biasa yang boleh login via API
        if ($user->role !== 'user') {
            return response()->json([
                'success' => false,
                'message' => 'Kredensial tidak valid',
            ], 401);
        }

        $token = $user->createToken('flutter-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'token' => $token,
                'user'  => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                    'role'  => $user->role,
                ],
            ],
        ]);
    }

    /**
     * POST /api/auth/logout
     * Logout — hapus token Sanctum yang aktif.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * GET /api/auth/me
     * Ambil data profil user yang sedang login.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data'    => [
                'id'         => $user->id,
                'name'       => $user->name,
                'email'      => $user->email,
                'role'       => $user->role,
                'created_at' => $user->created_at->toIso8601String(),
            ],
        ]);
    }
}
