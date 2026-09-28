<?php

namespace App\Console\Commands;

use App\Models\GoldPrice;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class SyncNewsMaker extends Command
{
    protected $signature = 'newsmaker:sync';

    protected $description = 'Sinkronisasi data LGD Daily dari News Maker ke database';

    public function handle(): int
    {
        $this->info('Mengambil data dari News Maker...');

        $url = 'https://www.newsmaker.id/id/tools/historical-data';

        try {
            $response = Http::timeout(30)->get($url);
        } catch (\Throwable $e) {
            $this->error(
                'Gagal mengakses News Maker: ' . $e->getMessage()
            );

            return self::FAILURE;
        }

        if (!$response->successful()) {
            $this->error(
                'News Maker mengembalikan HTTP ' . $response->status()
            );

            return self::FAILURE;
        }

        $html = $response->body();

        /*
         * Data News Maker berada dalam bentuk object JSON
         * yang di-escape di dalam HTML:
         *
         * {\"id\":...,\"tanggal\":..., ...}
         */
        $pattern = '/\{\\\\\"id\\\\\":.*?\}/';

        preg_match_all(
            $pattern,
            $html,
            $matches
        );

        $this->info(
            'Total object ditemukan: ' . count($matches[0])
        );

        $lgd = [];

        foreach ($matches[0] as $object) {

            /*
             * Mengubah:
             *
             * {\"id\":...}
             *
             * menjadi:
             *
             * {"id":...}
             */
            $clean = stripslashes($object);

            $data = json_decode($clean, true);

            if (!is_array($data)) {
                continue;
            }

            /*
             * Hanya ambil LGD Daily.
             */
            if (($data['category'] ?? null) !== 'LGD Daily') {
                continue;
            }

            /*
             * Pastikan semua data harga tersedia.
             */
            if (
                !isset($data['tanggal']) ||
                !isset($data['open']) ||
                !isset($data['high']) ||
                !isset($data['low']) ||
                !isset($data['close'])
            ) {
                continue;
            }

            /*
             * Pastikan harga bukan string kosong.
             */
            if (
                $data['open'] === '' ||
                $data['high'] === '' ||
                $data['low'] === '' ||
                $data['close'] === ''
            ) {
                continue;
            }

            $lgd[] = $data;
        }

        /*
         * Hilangkan kemungkinan duplikat berdasarkan tanggal.
         */
        $uniqueLgd = [];

        foreach ($lgd as $row) {
            $uniqueLgd[$row['tanggal']] = $row;
        }

        $lgd = array_values($uniqueLgd);

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

        $this->info(
            'Total LGD Daily valid: ' . count($lgd)
        );

        if (empty($lgd)) {
            $this->error('Tidak ada data LGD yang ditemukan.');

            return self::FAILURE;
        }

        $inserted = 0;
        $updated = 0;

        /*
         * Masukkan data satu per satu.
         */
        foreach ($lgd as $row) {

            $date = Carbon::parse(
                $row['tanggal']
            )->endOfDay();

            /*
             * Cari data LGD pada tanggal yang sama.
             */
            $existing = GoldPrice::where(
                'commodity',
                'LGD'
            )
                ->whereDate(
                    'recorded_at',
                    $row['tanggal']
                )
                ->first();

            $payload = [
                'commodity' => 'LGD',
                'price' => (float) $row['close'],
                'open' => (float) $row['open'],
                'high' => (float) $row['high'],
                'low' => (float) $row['low'],
                'close' => (float) $row['close'],
                'recorded_at' => $date,
            ];

            if ($existing) {

                $existing->update($payload);

                $updated++;
            } else {

                GoldPrice::create($payload);

                $inserted++;
            }
        }

        $this->newLine();

        $this->info('Sinkronisasi selesai!');

        $this->line(
            'Data baru ditambahkan : ' . $inserted
        );

        $this->line(
            'Data diperbarui       : ' . $updated
        );

        $this->line(
            'Total data News Maker : ' . count($lgd)
        );

        /*
         * Tampilkan data terbaru.
         */
        $latest = GoldPrice::where(
            'commodity',
            'LGD'
        )
            ->orderBy(
                'recorded_at',
                'desc'
            )
            ->first();

        if ($latest) {
            $this->newLine();

            $this->info('DATA LGD TERBARU DI DATABASE:');

            $this->line(
                'Tanggal : '
                . $latest->recorded_at->format('Y-m-d')
            );

            $this->line(
                'Open    : '
                . $latest->open
            );

            $this->line(
                'High    : '
                . $latest->high
            );

            $this->line(
                'Low     : '
                . $latest->low
            );

            $this->line(
                'Close   : '
                . $latest->close
            );
        }

        return self::SUCCESS;
    }
}