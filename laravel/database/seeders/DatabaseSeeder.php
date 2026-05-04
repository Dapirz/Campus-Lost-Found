<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::query()->updateOrCreate(
            ['email' => 'admin@campuslostfound.com'],
            [
                'name' => 'Campus Admin',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'is_active' => true,
                'fcm_token' => null,
            ],
        );

        $this->call([
            UserSeeder::class,
            ReportSeeder::class,
            ReportImageSeeder::class,
        ]);
    }
}
