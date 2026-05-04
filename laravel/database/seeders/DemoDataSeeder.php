<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\Report;
use App\Models\ReportImage;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;

class DemoDataSeeder extends Seeder
{
    /**
     * Seed demo data for local SQLite usage.
     */
    public function run(): void
    {
        if (app()->environment('production')) {
            return;
        }

        if (app()->environment('production')) {
            return;
        }

        $demoUsers = collect([
            ['name' => 'Andi Pratama', 'email' => 'andi@student.ac.id', 'is_active' => true],
            ['name' => 'Bunga Maharani', 'email' => 'bunga@student.ac.id', 'is_active' => true],
            ['name' => 'Cahyo Nugroho', 'email' => 'cahyo@student.ac.id', 'is_active' => true],
            ['name' => 'Dinda Lestari', 'email' => 'dinda@student.ac.id', 'is_active' => false],
            ['name' => 'Eko Saputra', 'email' => 'eko@student.ac.id', 'is_active' => true],
            ['name' => 'Farah Nabila', 'email' => 'farah@student.ac.id', 'is_active' => true],
            ['name' => 'Gilang Ramadhan', 'email' => 'gilang@student.ac.id', 'is_active' => true],
            ['name' => 'Hana Putri', 'email' => 'hana@student.ac.id', 'is_active' => true],
        ])->map(function (array $user): User {
            return User::query()->updateOrCreate(
                ['email' => $user['email']],
                [
                    'name' => $user['name'],
                    'password' => Hash::make('password'),
                    'role' => 'user',
                    'is_active' => $user['is_active'],
                    'fcm_token' => null,
                ],
            );
        });

        if (Report::query()->exists()) {
            return;
        }

        $reports = [
            [
                'user' => 'andi@student.ac.id',
                'type' => 'lost',
                'title' => 'Laptop ASUS Vivobook Biru',
                'description' => 'Tertinggal di ruang lab lantai 3 setelah kelas pemrograman web.',
                'location_text' => 'Lab Komputer Gedung A lantai 3',
                'latitude' => -6.20010000,
                'longitude' => 106.81670000,
                'status' => 'pending',
                'incident_date' => now()->subDays(2)->toDateString(),
                'created_at' => now()->subDays(2)->setTime(9, 15),
                'images' => ['https://placehold.co/600x400/png?text=Laptop+ASUS'],
            ],
            [
                'user' => 'bunga@student.ac.id',
                'type' => 'found',
                'title' => 'KTM atas nama Rizky Maulana',
                'description' => 'Ditemukan di dekat parkiran motor fakultas teknik.',
                'location_text' => 'Parkiran Motor Fakultas Teknik',
                'latitude' => -6.20100000,
                'longitude' => 106.81720000,
                'status' => 'verified',
                'incident_date' => now()->subDays(4)->toDateString(),
                'created_at' => now()->subDays(4)->setTime(13, 40),
                'images' => ['https://placehold.co/600x400/png?text=KTM'],
            ],
            [
                'user' => 'cahyo@student.ac.id',
                'type' => 'found',
                'title' => 'Kunci Motor dengan Gantungan Merah',
                'description' => 'Ditemukan di kantin belakang kampus saat jam makan siang.',
                'location_text' => 'Kantin Belakang Kampus',
                'latitude' => -6.19990000,
                'longitude' => 106.81810000,
                'status' => 'verified',
                'incident_date' => now()->subDays(3)->toDateString(),
                'created_at' => now()->subDays(3)->setTime(12, 5),
                'images' => ['https://placehold.co/600x400/png?text=Kunci+Motor'],
            ],
            [
                'user' => 'dinda@student.ac.id',
                'type' => 'lost',
                'title' => 'Tas Ransel Hitam Eiger',
                'description' => 'Diduga tertinggal di perpustakaan setelah mengerjakan tugas kelompok.',
                'location_text' => 'Perpustakaan Pusat',
                'latitude' => -6.20230000,
                'longitude' => 106.81590000,
                'status' => 'resolved',
                'incident_date' => now()->subDays(7)->toDateString(),
                'created_at' => now()->subDays(7)->setTime(15, 20),
                'images' => [
                    'https://placehold.co/600x400/png?text=Tas+Eiger',
                    'https://placehold.co/600x400/png?text=Isi+Tas',
                ],
            ],
            [
                'user' => 'eko@student.ac.id',
                'type' => 'lost',
                'title' => 'Jam Tangan Casio Silver',
                'description' => 'Hilang setelah kegiatan UKM di aula mahasiswa.',
                'location_text' => 'Aula Mahasiswa',
                'latitude' => -6.19870000,
                'longitude' => 106.81480000,
                'status' => 'verified',
                'incident_date' => now()->subDays(5)->toDateString(),
                'created_at' => now()->subDays(5)->setTime(18, 30),
                'images' => ['https://placehold.co/600x400/png?text=Jam+Tangan'],
            ],
            [
                'user' => 'farah@student.ac.id',
                'type' => 'found',
                'title' => 'Earbuds Putih tanpa Case',
                'description' => 'Ditemukan di kursi auditorium setelah seminar nasional.',
                'location_text' => 'Auditorium Utama',
                'latitude' => -6.19790000,
                'longitude' => 106.81900000,
                'status' => 'pending',
                'incident_date' => now()->subDay()->toDateString(),
                'created_at' => now()->subDay()->setTime(16, 10),
                'images' => [],
            ],
            [
                'user' => 'gilang@student.ac.id',
                'type' => 'lost',
                'title' => 'Botol Minum Tumbler Hijau',
                'description' => 'Botol minum hilang saat olahraga pagi di lapangan kampus.',
                'location_text' => 'Lapangan Kampus',
                'latitude' => -6.20310000,
                'longitude' => 106.81790000,
                'status' => 'verified',
                'incident_date' => now()->subDays(6)->toDateString(),
                'created_at' => now()->subDays(6)->setTime(7, 45),
                'images' => ['https://placehold.co/600x400/png?text=Tumbler'],
            ],
            [
                'user' => 'hana@student.ac.id',
                'type' => 'lost',
                'title' => 'KTP dalam Dompet Kecil Cokelat',
                'description' => 'Terakhir terlihat di sekitar halte kampus depan gerbang utama.',
                'location_text' => 'Halte Kampus Gerbang Utama',
                'latitude' => -6.20180000,
                'longitude' => 106.81390000,
                'status' => 'resolved',
                'incident_date' => now()->subDays(10)->toDateString(),
                'created_at' => now()->subDays(10)->setTime(8, 10),
                'images' => ['https://placehold.co/600x400/png?text=Dompet+Kecil'],
            ],
        ];

        $createdReports = collect($reports)->map(function (array $reportData) use ($demoUsers): Report {
            $user = $demoUsers->firstWhere('email', $reportData['user']);

            /** @var Report $report */
            $report = Report::query()->create([
                'user_id' => $user->id,
                'type' => $reportData['type'],
                'title' => $reportData['title'],
                'description' => $reportData['description'],
                'location_text' => $reportData['location_text'],
                'latitude' => $reportData['latitude'],
                'longitude' => $reportData['longitude'],
                'status' => $reportData['status'],
                'incident_date' => $reportData['incident_date'],
                'created_at' => $reportData['created_at'],
                'updated_at' => $reportData['created_at'],
            ]);

            foreach ($reportData['images'] as $imageUrl) {
                ReportImage::query()->create([
                    'report_id' => $report->id,
                    'image_url' => $imageUrl,
                    'created_at' => $reportData['created_at'],
                    'updated_at' => $reportData['created_at'],
                ]);
            }

            return $report;
        });

        $this->seedNotifications($demoUsers);
    }

    /**
     * @param  Collection<int, User>  $users
     */
    private function seedNotifications(Collection $users): void
    {
        $notifications = [
            [
                'email' => 'bunga@student.ac.id',
                'type' => 'report_verified',
                'message' => 'Laporan "KTM atas nama Rizky Maulana" kamu sudah diverifikasi dan dipublikasikan.',
            ],
            [
                'email' => 'eko@student.ac.id',
                'type' => 'report_verified',
                'message' => 'Laporan "Jam Tangan Casio Silver" kamu sudah diverifikasi dan dipublikasikan.',
            ],
            [
                'email' => 'andi@student.ac.id',
                'type' => 'report_rejected',
                'message' => 'Laporan "Flashdisk Merah 32GB" kamu ditolak karena tidak memenuhi ketentuan.',
            ],
            [
                'email' => 'gilang@student.ac.id',
                'type' => 'report_rejected',
                'message' => 'Laporan "Powerbank Tanpa Identitas" kamu ditolak karena tidak memenuhi ketentuan.',
            ],
        ];

        foreach ($notifications as $item) {
            $user = $users->firstWhere('email', $item['email']);

            Notification::query()->create([
                'user_id' => $user->id,
                'type' => $item['type'],
                'message' => $item['message'],
                'is_read' => false,
            ]);
        }
    }
}
