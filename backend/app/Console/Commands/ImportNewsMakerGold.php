<?php

namespace App\Console\Commands;

use App\Services\NewsMakerService;
use Illuminate\Console\Command;

class ImportNewsMakerGold extends Command
{
    protected $signature = 'newsmaker:import-gold';

    protected $description = 'Import data LGD Daily dari News Maker';

    public function handle(NewsMakerService $service): int
    {
        try {
            $count = $service->importLgd();

            $this->info("Berhasil import {$count} data emas.");

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }
    }
}