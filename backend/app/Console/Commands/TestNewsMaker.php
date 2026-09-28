<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class TestNewsMaker extends Command
{
    protected $signature = 'newsmaker:test';

    protected $description = 'Mengecek seluruh object data News Maker';

    public function handle(): int
    {
        $this->info('Mengambil data dari News Maker...');

        $url = 'https://www.newsmaker.id/id/tools/historical-data';

        $response = Http::timeout(30)->get($url);

        if (!$response->successful()) {
            $this->error(
                'HTTP Error: ' . $response->status()
            );

            return self::FAILURE;
        }

        $html = $response->body();

        /*
         * Ambil SATU object JSON pada satu waktu.
         *
         * Bentuk data di HTML:
         * {\"id\":...,\"tanggal\":..., ...}
         */
        $pattern = '/\{\\\\\"id\\\\\":.*?\}/';

        preg_match_all(
            $pattern,
            $html,
            $matches
        );

        $this->info(
            'Total object yang ditemukan: '
            . count($matches[0])
        );

        $lgd = [];

        foreach ($matches[0] as $object) {

            /*
             * Ubah:
             * {\"id\":...}
             *
             * menjadi:
             * {"id":...}
             */
            $clean = stripslashes($object);

            $data = json_decode($clean, true);

            if (!is_array($data)) {
                continue;
            }

            /*
             * Ambil hanya LGD Daily.
             */
            if (
                ($data['category'] ?? null)
                !== 'LGD Daily'
            ) {
                continue;
            }

            /*
             * Pastikan field harga tersedia.
             */
            if (
                !isset($data['id'])
                || !isset($data['tanggal'])
                || !isset($data['open'])
                || !isset($data['high'])
                || !isset($data['low'])
                || !isset($data['close'])
            ) {
                continue;
            }

            $lgd[] = $data;
        }

        $this->newLine();

        $this->info(
            'Total LGD Daily yang berhasil ditemukan: '
            . count($lgd)
        );
$this->newLine();
$this->info('MENGECEK DATA LGD DENGAN HARGA KOSONG...');

$emptyPriceData = [];

foreach ($lgd as $row) {
    if (
        $row['open'] === null
        || $row['high'] === null
        || $row['low'] === null
        || $row['close'] === null
        || $row['open'] === ''
        || $row['high'] === ''
        || $row['low'] === ''
        || $row['close'] === ''
    ) {
        $emptyPriceData[] = $row;
    }
}

if (empty($emptyPriceData)) {
    $this->info(
        'Semua 250 data LGD memiliki Open, High, Low, dan Close.'
    );
} else {
    $this->warn(
        'Ditemukan ' . count($emptyPriceData)
        . ' data LGD dengan harga kosong:'
    );

    foreach ($emptyPriceData as $row) {
        $this->line(
            'ID ' . $row['id']
            . ' | ' . $row['tanggal']
            . ' | Open ' . ($row['open'] ?? 'NULL')
            . ' | High ' . ($row['high'] ?? 'NULL')
            . ' | Low ' . ($row['low'] ?? 'NULL')
            . ' | Close ' . ($row['close'] ?? 'NULL')
        );
    }
}

        /*
         * Urutkan berdasarkan tanggal.
         */
        usort(
            $lgd,
            function ($a, $b) {
                return strcmp(
                    $a['tanggal'],
                    $b['tanggal']
                );
            }
        );

        /*
         * Tampilkan 10 pertama.
         */
        $this->newLine();
        $this->info('10 DATA LGD PERTAMA:');

        foreach (array_slice($lgd, 0, 10) as $row) {
            $this->line(
                'ID ' . $row['id']
                . ' | ' . $row['tanggal']
                . ' | Open ' . $row['open']
                . ' | High ' . $row['high']
                . ' | Low ' . $row['low']
                . ' | Close ' . $row['close']
            );
        }

        /*
         * Tampilkan 10 terakhir.
         */
        $this->newLine();
        $this->info('10 DATA LGD TERAKHIR:');

        foreach (array_slice($lgd, -10) as $row) {
            $this->line(
                'ID ' . $row['id']
                . ' | ' . $row['tanggal']
                . ' | Open ' . $row['open']
                . ' | High ' . $row['high']
                . ' | Low ' . $row['low']
                . ' | Close ' . $row['close']
            );
        }

        /*
         * Cek tanggal duplikat.
         */
        $this->newLine();
        $this->info('MENGECEK TANGGAL DUPLIKAT...');

        $dateCounts = [];

        foreach ($lgd as $row) {
            $date = $row['tanggal'];

            if (!isset($dateCounts[$date])) {
                $dateCounts[$date] = 0;
            }

            $dateCounts[$date]++;
        }

        $duplicates = [];

        foreach ($dateCounts as $date => $count) {
            if ($count > 1) {
                $duplicates[$date] = $count;
            }
        }

        if (empty($duplicates)) {
            $this->info(
                'Tidak ada tanggal LGD yang duplikat.'
            );
        } else {
            foreach ($duplicates as $date => $count) {
                $this->warn(
                    $date . ' muncul ' . $count . ' kali'
                );
            }
        }

        /*
         * Cek tanggal paling awal dan paling akhir.
         */
        $this->newLine();
        $this->info('RENTANG DATA LGD:');

        if (!empty($lgd)) {
            $this->line(
                'Tanggal pertama: '
                . $lgd[0]['tanggal']
            );

            $this->line(
                'Tanggal terakhir: '
                . $lgd[count($lgd) - 1]['tanggal']
            );
        }

        $this->newLine();

        $this->info(
            'Database tidak diubah.'
        );

        return self::SUCCESS;
    }
}