<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GoldPrice;

class PivotPointController extends Controller
{
    public function index()
    {
        $goldPrice = GoldPrice::where('commodity', 'LGD')
            ->orderByDesc('recorded_at')
            ->first();

        if (!$goldPrice) {
            return response()->json([
                'message' => 'Data harga LGD belum tersedia.',
                'data' => null,
            ], 404);
        }

        $high = (float) $goldPrice->high;
        $low = (float) $goldPrice->low;
        $close = (float) $goldPrice->close;

        /*
         * Rumus Pivot Point Standard
         *
         * PP = (High + Low + Close) / 3
         *
         * R1 = (2 × PP) - Low
         * S1 = (2 × PP) - High
         *
         * R2 = PP + (High - Low)
         * S2 = PP - (High - Low)
         *
         * R3 = High + 2 × (PP - Low)
         * S3 = Low - 2 × (High - PP)
         *
         * R4 dan S4 digunakan sebagai level lanjutan.
         */

        $pp = ($high + $low + $close) / 3;

        $range = $high - $low;

        $r1 = (2 * $pp) - $low;
        $s1 = (2 * $pp) - $high;

        $r2 = $pp + $range;
        $s2 = $pp - $range;

        $r3 = $high + (2 * ($pp - $low));
        $s3 = $low - (2 * ($high - $pp));

        $r4 = $r3 + $range;
        $s4 = $s3 - $range;

        /*
         * BUY / SELL
         *
         * Untuk sementara level BUY menggunakan R1
         * dan SELL menggunakan S1 sebagai referensi.
         */

        $buy = $r1;
        $sell = $s1;

        /*
         * NEST
         *
         * NEST digunakan sebagai area tengah
         * antara support dan resistance terdekat.
         */

        $nest = ($s1 + $r1) / 2;

        return response()->json([
            'message' => 'Data pivot point berhasil diambil.',
            'data' => [
                'commodity' => 'LGD',
                'date' => $goldPrice->recorded_at?->format('Y-m-d'),

                'source' => [
                    'open' => (float) $goldPrice->open,
                    'high' => $high,
                    'low' => $low,
                    'close' => $close,
                ],

                'pivot' => round($pp, 2),
                'buy' => round($buy, 2),
                'sell' => round($sell, 2),
                'range' => round($range, 2),

                'resistance' => [
                    'r1' => round($r1, 2),
                    'r2' => round($r2, 2),
                    'r3' => round($r3, 2),
                    'r4' => round($r4, 2),
                ],

                'support' => [
                    's1' => round($s1, 2),
                    's2' => round($s2, 2),
                    's3' => round($s3, 2),
                    's4' => round($s4, 2),
                ],

                'nest' => round($nest, 2),

                'unit' => 'USD / t.oz',
            ],
        ]);
    }
}