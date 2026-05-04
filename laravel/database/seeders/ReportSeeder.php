<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\Report;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class ReportSeeder extends Seeder
{
    /**
     * Seed the application's reports.
     */
    public function run(): void
    {
        Notification::query()
            ->whereIn('type', ['report_verified', 'report_rejected'])
            ->delete();

        Report::query()->delete();

        $users = User::query()
            ->where('role', 'user')
            ->get()
            ->keyBy('email');

        $reports = [
            [
                'user_email' => 'budi@student.telkomuniversity.ac.id',
                'type' => 'lost',
                'title' => 'Dompet Kulit Cokelat',
                'description' => 'Dompet tertinggal setelah makan siang dan berisi kartu penting serta uang tunai.',
                'location_text' => 'Kantin FIF Lantai 1',
                'latitude' => -6.97385000,
                'longitude' => 107.63020000,
                'status' => 'pending',
                'admin_notes' => null,
                'incident_date' => '2026-04-03',
                'reported_at' => '2026-04-03 13:15:00',
            ],
            [
                'user_email' => 'siti@student.telkomuniversity.ac.id',
                'type' => 'lost',
                'title' => 'Laptop ASUS VivoBook Biru',
                'description' => 'Laptop tertinggal setelah kelas praktikum dan terakhir terlihat di meja pojok dekat proyektor.',
                'location_text' => 'Gedung B Ruang 301',
                'latitude' => -6.97370000,
                'longitude' => 107.62985000,
                'status' => 'pending',
                'admin_notes' => null,
                'incident_date' => '2026-04-02',
                'reported_at' => '2026-04-02 09:15:00',
            ],
            [
                'user_email' => 'andi@student.telkomuniversity.ac.id',
                'type' => 'found',
                'title' => 'Kunci Motor Honda dengan Gantungan Merah',
                'description' => 'Ditemukan di area parkir motor dekat jalur keluar masuk mahasiswa.',
                'location_text' => 'Parkiran Gedung A',
                'latitude' => -6.97405000,
                'longitude' => 107.63045000,
                'status' => 'pending',
                'admin_notes' => null,
                'incident_date' => '2026-04-01',
                'reported_at' => '2026-04-01 16:10:00',
            ],
            [
                'user_email' => 'farah@student.telkomuniversity.ac.id',
                'type' => 'found',
                'title' => 'KTM Fakultas Informatika',
                'description' => 'Kartu mahasiswa ditemukan di lorong menuju perpustakaan dan masih dalam kondisi baik.',
                'location_text' => 'Perpustakaan Pusat Lt. 2',
                'latitude' => -6.97340000,
                'longitude' => 107.62950000,
                'status' => 'verified',
                'admin_notes' => null,
                'incident_date' => '2026-03-31',
                'reported_at' => '2026-03-31 10:20:00',
            ],
            [
                'user_email' => 'cahyo@student.telkomuniversity.ac.id',
                'type' => 'found',
                'title' => 'Earbuds Putih tanpa Case',
                'description' => 'Earbuds ditemukan setelah acara seminar dan diletakkan sementara di meja registrasi.',
                'location_text' => 'Auditorium Universitas',
                'latitude' => -6.97325000,
                'longitude' => 107.62910000,
                'status' => 'verified',
                'admin_notes' => null,
                'incident_date' => '2026-03-30',
                'reported_at' => '2026-03-30 15:45:00',
            ],
            [
                'user_email' => 'budi@student.telkomuniversity.ac.id',
                'type' => 'found',
                'title' => 'Charger Laptop Hitam',
                'description' => 'Charger ditemukan tergeletak di dekat stop kontak setelah ruang kelas kosong.',
                'location_text' => 'Gedung Tokong Nanas Ruang 210',
                'latitude' => -6.97392000,
                'longitude' => 107.62968000,
                'status' => 'verified',
                'admin_notes' => null,
                'incident_date' => '2026-03-29',
                'reported_at' => '2026-03-29 11:35:00',
            ],
            [
                'user_email' => 'andi@student.telkomuniversity.ac.id',
                'type' => 'lost',
                'title' => 'Dompet Hitam dengan Kartu ATM',
                'description' => 'Dompet hilang saat menunggu kelas sore dan kemungkinan tertinggal di bangku area terbuka.',
                'location_text' => 'Selasar Gedung C',
                'latitude' => -6.97358000,
                'longitude' => 107.62996000,
                'status' => 'verified',
                'admin_notes' => null,
                'incident_date' => '2026-03-28',
                'reported_at' => '2026-03-28 17:05:00',
            ],
            [
                'user_email' => 'siti@student.telkomuniversity.ac.id',
                'type' => 'lost',
                'title' => 'KTM dan KTP dalam Holder Transparan',
                'description' => 'Holder kartu hilang setelah salat dzuhur dan terakhir terlihat di rak sepatu dekat pintu masuk.',
                'location_text' => 'Masjid Kampus',
                'latitude' => -6.97415000,
                'longitude' => 107.62925000,
                'status' => 'resolved',
                'admin_notes' => null,
                'incident_date' => '2026-03-27',
                'reported_at' => '2026-03-27 13:40:00',
            ],
            [
                'user_email' => 'farah@student.telkomuniversity.ac.id',
                'type' => 'found',
                'title' => 'Earbuds Case Abu-abu',
                'description' => 'Case earbuds ditemukan di meja baca dan sudah diserahkan kembali ke pemiliknya.',
                'location_text' => 'Open Library Area Diskusi',
                'latitude' => -6.97330000,
                'longitude' => 107.62942000,
                'status' => 'resolved',
                'admin_notes' => null,
                'incident_date' => '2026-03-26',
                'reported_at' => '2026-03-26 14:25:00',
            ],
            [
                'user_email' => 'cahyo@student.telkomuniversity.ac.id',
                'type' => 'lost',
                'title' => 'Kunci Loker Laboratorium',
                'description' => 'Kunci hilang, tetapi foto yang diunggah tidak jelas dan informasi ciri fisik kunci sangat minim.',
                'location_text' => 'Laboratorium Multimedia Gedung A',
                'latitude' => -6.97396000,
                'longitude' => 107.63008000,
                'status' => 'rejected',
                'admin_notes' => 'Foto tidak jelas dan deskripsi belum cukup untuk proses verifikasi.',
                'incident_date' => '2026-03-25',
                'reported_at' => '2026-03-25 08:55:00',
            ],
        ];

        foreach ($reports as $reportData) {
            $user = $users->get($reportData['user_email']);
            $reportedAt = Carbon::parse($reportData['reported_at']);

            $report = Report::query()->create([
                'user_id' => $user?->id,
                'type' => $reportData['type'],
                'title' => $reportData['title'],
                'description' => $reportData['description'],
                'location_text' => $reportData['location_text'],
                'latitude' => $reportData['latitude'],
                'longitude' => $reportData['longitude'],
                'status' => $reportData['status'],
                'admin_notes' => $reportData['admin_notes'],
                'incident_date' => $reportData['incident_date'],
                'created_at' => $reportedAt,
                'updated_at' => $reportedAt,
            ]);

            if (in_array($report->status, ['verified', 'resolved'], true)) {
                Notification::query()->create([
                    'user_id' => $report->user_id,
                    'type' => 'report_verified',
                    'message' => 'Your report "'.$report->title.'" has been verified and published.',
                    'is_read' => false,
                    'created_at' => $reportedAt,
                    'updated_at' => $reportedAt,
                ]);
            }

            if ($report->status === 'rejected') {
                $message = 'Your report "'.$report->title.'" has been rejected by the admin.';

                if (! empty($reportData['admin_notes'])) {
                    $message .= ' Rejection reason: '.$reportData['admin_notes'];
                }

                Notification::query()->create([
                    'user_id' => $report->user_id,
                    'type' => 'report_rejected',
                    'message' => $message,
                    'is_read' => false,
                    'created_at' => $reportedAt,
                    'updated_at' => $reportedAt,
                ]);
            }
        }
    }
}
