<?php
$u = App\Models\User::where('email', 'andi@student.telkomuniversity.ac.id')->first();
$u->password = Illuminate\Support\Facades\Hash::make('password');
$u->save();
echo "PASSWORD UPDATED";
