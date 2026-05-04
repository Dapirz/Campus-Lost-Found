<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Seed the application's dummy student users.
     */
    public function run(): void
    {
        $users = [
            ['name' => 'Budi Santoso', 'email' => 'budi@student.telkomuniversity.ac.id'],
            ['name' => 'Siti Aminah', 'email' => 'siti@student.telkomuniversity.ac.id'],
            ['name' => 'Andi Pratama', 'email' => 'andi@student.telkomuniversity.ac.id'],
            ['name' => 'Farah Nabila', 'email' => 'farah@student.telkomuniversity.ac.id'],
            ['name' => 'Cahyo Nugroho', 'email' => 'cahyo@student.telkomuniversity.ac.id'],
        ];

        foreach ($users as $user) {
            User::query()->updateOrCreate(
                ['email' => $user['email']],
                [
                    'name' => $user['name'],
                    'password' => Hash::make('password123'),
                    'role' => 'user',
                    'is_active' => true,
                    'fcm_token' => null,
                ],
            );
        }
    }
}
