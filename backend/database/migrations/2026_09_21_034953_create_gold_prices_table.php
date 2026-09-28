<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('gold_prices', function (Blueprint $table) {
        $table->id();

        $table->string('commodity', 20);
        $table->decimal('price', 15, 2);

        $table->decimal('open', 15, 2)->nullable();
        $table->decimal('high', 15, 2)->nullable();
        $table->decimal('low', 15, 2)->nullable();
        $table->decimal('close', 15, 2)->nullable();

        $table->timestamp('recorded_at')->nullable();

        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gold_prices');
    }
};
