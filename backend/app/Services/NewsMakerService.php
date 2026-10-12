<?php

namespace App\Services;

use App\Models\GoldPrice;
use Illuminate\Support\Facades\Http;

class NewsMakerService
{
    private string $url =
        'https://www.newsmaker.id/api/historical-data';

    public function importLgd(): int
    {
        $response = Http::timeout(30)
            ->acceptJson()
            ->get($this->url);

        if (!$response->successful()) {
            throw new \Exception(
                'Gagal mengambil data dari News Maker. HTTP ' .
                $response->status()
            );
        }

        $items = $response->json('data', []);

        if (empty($items)) {
            throw new \Exception(
                'Data historis News Maker kosong.'
            );
        }

        $imported = 0;

        foreach ($items as $item) {
            if (($item['category'] ?? '') !== 'LGD Daily') {
                continue;
            }

            if (
                empty($item['tanggal']) ||
                $item['open'] === null ||
                $item['high'] === null ||
                $item['low'] === null ||
                $item['close'] === null
            ) {
                continue;
            }

            GoldPrice::updateOrCreate(
                [
                    'commodity' => 'LGD',
                    'recorded_at' => $item['tanggal'] . ' 00:00:00',
                ],
                [
                    'price' => $item['close'],
                    'open' => $item['open'],
                    'high' => $item['high'],
                    'low' => $item['low'],
                    'close' => $item['close'],
                ]
            );

            $imported++;
        }

        return $imported;
    }
}