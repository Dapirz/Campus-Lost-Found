<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::statement("UPDATE reports SET status = 'verified' WHERE status = 'claimed'");

        DB::statement("ALTER TABLE reports 
            MODIFY COLUMN status 
            ENUM('pending','verified','resolved') 
            DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("ALTER TABLE reports 
            MODIFY COLUMN status 
            ENUM('pending','verified','claimed','resolved') 
            DEFAULT 'pending'");
    }
};
