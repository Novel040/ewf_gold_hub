<?php

namespace App\Services;

use App\Models\GoldPrice;
use Illuminate\Support\Facades\Http;

class NewsMakerService
{
    private string $url =
        'https://www.newsmaker.id/id/tools/historical-data';

    public function importLgd(): int
    {
        $response = Http::timeout(30)->get($this->url);

        if (!$response->successful()) {
            throw new \Exception(
                'Gagal mengambil data dari News Maker. HTTP ' .
                $response->status()
            );
        }

        $html = $response->body();

        if (empty($html)) {
            throw new \Exception(
                'Response News Maker kosong.'
            );
        }

        /*
         * News Maker menampilkan data LGD Daily
         * dalam tabel HTML dengan format:
         *
         * Tanggal | Open | High | Low | Close
         */
        $pattern = '/<tr[^>]*>\s*'
            . '<td[^>]*>\s*(\d{4}-\d{2}-\d{2})\s*<\/td>\s*'
            . '<td[^>]*>\s*([\d.]+)\s*<\/td>\s*'
            . '<td[^>]*>\s*([\d.]+)\s*<\/td>\s*'
            . '<td[^>]*>\s*([\d.]+)\s*<\/td>\s*'
            . '<td[^>]*>\s*([\d.]+)\s*<\/td>\s*'
            . '<\/tr>/i';

        preg_match_all(
            $pattern,
            $html,
            $matches,
            PREG_SET_ORDER
        );

        if (empty($matches)) {
            throw new \Exception(
                'Data historis LGD tidak ditemukan.'
            );
        }

        $imported = 0;

        foreach ($matches as $row) {
            $date = $row[1];

            $open = (float) $row[2];
            $high = (float) $row[3];
            $low = (float) $row[4];
            $close = (float) $row[5];

            GoldPrice::updateOrCreate(
                [
                    'commodity' => 'LGD',
                    'recorded_at' => $date . ' 00:00:00',
                ],
                [
                    'price' => $close,
                    'open' => $open,
                    'high' => $high,
                    'low' => $low,
                    'close' => $close,
                ]
            );

            $imported++;
        }

        return $imported;
    }
}