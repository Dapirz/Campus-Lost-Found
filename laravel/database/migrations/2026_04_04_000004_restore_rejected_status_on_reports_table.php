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
        DB::statement("ALTER TABLE reports 
            MODIFY COLUMN status 
            ENUM('pending','verified','resolved','rejected') 
            DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("UPDATE reports SET status = 'pending' WHERE status = 'rejected'");

        DB::statement("ALTER TABLE reports 
            MODIFY COLUMN status 
            ENUM('pending','verified','resolved') 
            DEFAULT 'pending'");
    }
};
