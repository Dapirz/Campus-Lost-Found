<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\ReportImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ReportController extends Controller
{
    /**
     * GET /api/reports
     * Ambil daftar laporan yang sudah diverifikasi admin (status = verified).
     * Mendukung filter type, category_id, search, dan pagination.
     */
    public function index(Request $request): JsonResponse
    {
        $reports = Report::query()
            ->with(['user:id,name', 'reportImages'])
            ->where(function ($query) {
                // Tampilkan laporan yang terverifikasi (untuk semua user)
                $query->where('status', 'verified');
                
                // ATAU tampilkan laporan berstatus collection_pending KHUSUS untuk user yang klaimnya disetujui
                $user = auth('sanctum')->user();
                if ($user) {
                    $query->orWhere(function ($sub) use ($user) {
                        $sub->where('status', 'collection_pending')
                            ->whereHas('claims', function ($claimQuery) use ($user) {
                                $claimQuery->where('user_id', $user->id)
                                           ->where('status', 'approved');
                            });
                    });
                }
            })
            ->when($request->string('type')->value(), function ($query, string $type) {
                $query->where('type', $type);
            })
            ->when($request->string('search')->trim()->value(), function ($query, string $search) {
                $query->where(function ($sub) use ($search): void {
                    $sub->where('title', 'like', '%'.$search.'%')
                        ->orWhere('description', 'like', '%'.$search.'%');
                });
            })
            ->latest()
            ->paginate(15);

        // Transform paginated data
        $reports->getCollection()->transform(function (Report $report) {
            return [
                'id'            => $report->id,
                'type'          => $report->type,
                'title'         => $report->title,
                'location_text' => $report->location_text,
                'incident_date' => $report->incident_date?->format('Y-m-d'),
                'status'        => $report->status,
                'image_url'     => $report->image_url,
                'reporter'      => $report->user ? ['id' => $report->user->id, 'name' => $report->user->name] : null,
                'created_at'    => $report->created_at->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $reports,
        ]);
    }

    /**
     * GET /api/reports/{id}
     * Ambil detail satu laporan berdasarkan ID.
     */
    public function show(int $id): JsonResponse
    {
        $report = Report::query()
            ->with(['user:id,name', 'reportImages'])
            ->find($id);

        if (! $report) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan',
            ], 404);
        }

        // Cari apakah ada klaim aktif oleh user yang sedang login
        $activeClaim = null;
        $user = auth('sanctum')->user();
        if ($user) {
            $claim = \App\Models\Claim::query()
                ->where('report_id', $report->id)
                ->where('user_id', $user->id)
                ->first();

            if ($claim) {
                $activeClaim = [
                    'id'         => $claim->id,
                    'status'     => $claim->status,
                    'claim_code' => $claim->claim_code,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id'            => $report->id,
                'type'          => $report->type,
                'title'         => $report->title,
                'description'   => $report->description,
                'location_text' => $report->location_text,
                'latitude'      => $report->latitude,
                'longitude'     => $report->longitude,
                'incident_date' => $report->incident_date?->format('Y-m-d'),
                'status'        => $report->status,
                'rejection_reason' => $report->rejection_reason,
                'admin_notes'   => $report->admin_notes,
                'images'        => $report->reportImages->map(fn (ReportImage $img) => [
                    'id'  => $img->id,
                    'url' => $img->image_url,
                ]),
                'reporter'   => $report->user ? ['id' => $report->user->id, 'name' => $report->user->name] : null,
                'active_claim' => $activeClaim,
                'created_at' => $report->created_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * POST /api/reports
     * Buat laporan baru (hilang atau ditemukan). Status otomatis pending.
     * Request bisa berupa multipart/form-data kalau ada upload gambar.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type'          => ['required', 'string', 'in:lost,found'],
            'title'         => ['required', 'string', 'max:255'],
            'description'   => ['required', 'string'],
            'location_text' => ['required', 'string', 'max:255'],
            'incident_date' => ['required', 'date', 'date_format:Y-m-d'],
            'images'        => ['nullable', 'array'],
            'images.*'      => ['image', 'mimes:jpg,jpeg,png', 'max:2048'],
            'latitude'      => ['nullable', 'numeric', 'between:-90,90'],
            'longitude'     => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $report = DB::transaction(function () use ($validated, $request) {
            $report = Report::query()->create([
                'user_id'       => $request->user()->id,
                'type'          => $validated['type'],
                'title'         => $validated['title'],
                'description'   => $validated['description'],
                'location_text' => $validated['location_text'],
                'incident_date' => $validated['incident_date'],
                'latitude'      => $validated['latitude'] ?? null,
                'longitude'     => $validated['longitude'] ?? null,
                'status'        => 'pending',
            ]);

            // Upload gambar jika ada
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $image) {
                    $path = $image->store('reports', 'public');
                    $url  = url('/storage/'.$path);

                    $report->reportImages()->create([
                        'image_url' => $url,
                    ]);
                }
            }

            return $report;
        });

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dikirim dan menunggu verifikasi admin',
            'data'    => [
                'id'     => $report->id,
                'title'  => $report->title,
                'status' => $report->status,
            ],
        ], 201);
    }

    /**
     * GET /api/reports/my
     * Ambil semua laporan milik user yang sedang login (semua status).
     */
    public function my(Request $request): JsonResponse
    {
        $reports = Report::query()
            ->with('reportImages')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(function (Report $report) {
                return [
                    'id'            => $report->id,
                    'title'         => $report->title,
                    'type'          => $report->type,
                    'description'   => $report->description,
                    'location_text' => $report->location_text,
                    'incident_date' => $report->incident_date?->format('Y-m-d'),
                    'status'        => $report->status,
                    'image_url'     => $report->image_url,
                    'rejection_reason' => $report->rejection_reason,
                    'admin_notes'   => $report->admin_notes,
                    'created_at'    => $report->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $reports,
        ]);
    }

    /**
     * DELETE /api/reports/{id}
     * Hapus laporan milik sendiri.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $report = Report::query()->with('reportImages')->find($id);

        if (! $report) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan',
            ], 404);
        }

        if ($report->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak',
            ], 403);
        }

        // Hapus gambar dari storage
        foreach ($report->reportImages as $image) {
            $path = $this->resolveStoragePath($image->image_url);
            if ($path && Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
        }

        $report->delete();

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dihapus',
        ]);
    }

    /**
     * PATCH /api/reports/{id}/resolve
     * Pelapor menandai laporannya sebagai selesai.
     */
    public function resolve(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $report = Report::query()->find($id);

        if (! $report) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan',
            ], 404);
        }

        if ($report->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak atau laporan belum diverifikasi',
            ], 403);
        }

        if ($report->status !== 'verified') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak atau laporan belum diverifikasi',
            ], 403);
        }

        $report->update([
            'status'       => 'resolved',
            'resolve_note' => $validated['note'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Laporan ditandai sebagai selesai',
            'data'    => [
                'id'     => $report->id,
                'status' => 'resolved',
            ],
        ]);
    }

    /**
     * Resolve storage path dari image URL.
     */
    private function resolveStoragePath(?string $imageUrl): ?string
    {
        if (blank($imageUrl)) {
            return null;
        }

        $path = parse_url($imageUrl, PHP_URL_PATH) ?: $imageUrl;
        $normalizedPath = str_replace('\\', '/', $path);

        if (str_starts_with($normalizedPath, '/storage/')) {
            return ltrim(substr($normalizedPath, strlen('/storage/')), '/');
        }

        if (str_starts_with($normalizedPath, 'storage/')) {
            return ltrim(substr($normalizedPath, strlen('storage/')), '/');
        }

        return null;
    }
}
