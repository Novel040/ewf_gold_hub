<?php

namespace App\Console\Commands;

use App\Models\GoldPrice;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class SyncNewsMaker extends Command
{
    protected $signature = 'newsmaker:sync';

    protected $description = 'Sinkronisasi data LGD Daily dan HSI Daily dari News Maker ke database';

    public function handle(): int
    {
        $this->info('Mengambil data dari News Maker API...');

        $url = 'https://www.newsmaker.id/api/historical-data';

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

        $json = $response->json();

        if (!is_array($json)) {
            $this->error('Respons News Maker tidak valid.');

            return self::FAILURE;
        }

        if (!isset($json['data']) || !is_array($json['data'])) {
            $this->error('Data historical dari News Maker tidak ditemukan.');

            return self::FAILURE;
        }

        $rows = $json['data'];

        $this->info(
            'Total data dari API: ' . count($rows)
        );

        $lgd = [];
        $hsi = [];

        foreach ($rows as $data) {
            if (!is_array($data)) {
                continue;
            }

            $category = $data['category'] ?? null;

            if (
                $category !== 'LGD Daily' &&
                $category !== 'HSI Daily'
            ) {
                continue;
            }

            if (
                !isset($data['tanggal']) ||
                !isset($data['open']) ||
                !isset($data['high']) ||
                !isset($data['low']) ||
                !isset($data['close'])
            ) {
                continue;
            }

            if (
                $data['open'] === '' ||
                $data['high'] === '' ||
                $data['low'] === '' ||
                $data['close'] === ''
            ) {
                continue;
            }

            if ($category === 'LGD Daily') {
                $lgd[] = $data;
            }

            if ($category === 'HSI Daily') {
                $hsi[] = $data;
            }
        }

        $uniqueLgd = [];

        foreach ($lgd as $row) {
            $uniqueLgd[$row['tanggal']] = $row;
        }

        $lgd = array_values($uniqueLgd);

        $uniqueHsi = [];

        foreach ($hsi as $row) {
            $uniqueHsi[$row['tanggal']] = $row;
        }

        $hsi = array_values($uniqueHsi);

        usort($lgd, function ($a, $b) {
            return strcmp($a['tanggal'], $b['tanggal']);
        });

        usort($hsi, function ($a, $b) {
            return strcmp($a['tanggal'], $b['tanggal']);
        });

        $this->info(
            'Total LGD Daily valid: ' . count($lgd)
        );

        $this->info(
            'Total HSI Daily valid: ' . count($hsi)
        );

        if (empty($lgd) && empty($hsi)) {
            $this->error(
                'Tidak ada data LGD Daily atau HSI Daily yang ditemukan.'
            );

            return self::FAILURE;
        }

        $insertedLgd = 0;
        $updatedLgd = 0;

        $insertedHsi = 0;
        $updatedHsi = 0;

        foreach ($lgd as $row) {
            $date = Carbon::parse($row['tanggal'])->endOfDay();

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
                $updatedLgd++;
            } else {
                GoldPrice::create($payload);
                $insertedLgd++;
            }
        }

        foreach ($hsi as $row) {
            $date = Carbon::parse($row['tanggal'])->endOfDay();

            $existing = GoldPrice::where(
                'commodity',
                'HSI'
            )
                ->whereDate(
                    'recorded_at',
                    $row['tanggal']
                )
                ->first();

            $payload = [
                'commodity' => 'HSI',
                'price' => (float) $row['close'],
                'open' => (float) $row['open'],
                'high' => (float) $row['high'],
                'low' => (float) $row['low'],
                'close' => (float) $row['close'],
                'recorded_at' => $date,
            ];

            if ($existing) {
                $existing->update($payload);
                $updatedHsi++;
            } else {
                GoldPrice::create($payload);
                $insertedHsi++;
            }
        }

        $this->newLine();

        $this->info('Sinkronisasi selesai!');

        $this->line(
            'LGD baru ditambahkan : ' . $insertedLgd
        );

        $this->line(
            'LGD diperbarui       : ' . $updatedLgd
        );

        $this->line(
            'HSI baru ditambahkan : ' . $insertedHsi
        );

        $this->line(
            'HSI diperbarui       : ' . $updatedHsi
        );

        $this->line(
            'Total LGD News Maker : ' . count($lgd)
        );

        $this->line(
            'Total HSI News Maker : ' . count($hsi)
        );

        $latestLgd = GoldPrice::where(
            'commodity',
            'LGD'
        )
            ->orderBy(
                'recorded_at',
                'desc'
            )
            ->first();

        if ($latestLgd) {
            $this->newLine();

            $this->info(
                'DATA LGD TERBARU DI DATABASE:'
            );

            $this->line(
                'Tanggal : '
                . $latestLgd->recorded_at->format('Y-m-d')
            );

            $this->line(
                'Open    : ' . $latestLgd->open
            );

            $this->line(
                'High    : ' . $latestLgd->high
            );

            $this->line(
                'Low     : ' . $latestLgd->low
            );

            $this->line(
                'Close   : ' . $latestLgd->close
            );
        }

        $latestHsi = GoldPrice::where(
            'commodity',
            'HSI'
        )
            ->orderBy(
                'recorded_at',
                'desc'
            )
            ->first();

        if ($latestHsi) {
            $this->newLine();

            $this->info(
                'DATA HSI TERBARU DI DATABASE:'
            );

            $this->line(
                'DATA HSI TERBARU DI DATABASE:'
            );

            $this->line(
                'Tanggal : '
                . $latestHsi->recorded_at->format('Y-m-d')
            );

            $this->line(
                'Open    : ' . $latestHsi->open
            );

            $this->line(
                'High    : ' . $latestHsi->high
            );

            $this->line(
                'Low     : ' . $latestHsi->low
            );

            $this->line(
                'Close   : ' . $latestHsi->close
            );
        }

        return self::SUCCESS;
    }
}