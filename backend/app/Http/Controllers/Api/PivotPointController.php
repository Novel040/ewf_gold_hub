<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GoldPrice;
use Illuminate\Http\Request;

class PivotPointController extends Controller
{
    public function index(Request $request)
    {
        // Ambil commodity dari request
        // Default: LGD
        $commodity = strtoupper(
            $request->query('commodity', 'LGD')
        );

        // Validasi commodity
        if (!in_array($commodity, ['LGD', 'HSI'])) {
            return response()->json([
                'message' => 'Commodity tidak valid. Gunakan LGD atau HSI.',
                'data' => null,
            ], 400);
        }

        // Ambil data harga terbaru berdasarkan commodity
        $goldPrice = GoldPrice::where('commodity', $commodity)
            ->orderByDesc('recorded_at')
            ->first();

        // Jika data belum tersedia
        if (!$goldPrice) {
            return response()->json([
                'message' => "Data harga {$commodity} belum tersedia.",
                'data' => null,
            ], 404);
        }

        // Harga OHLC
        $open = (float) $goldPrice->open;
        $high = (float) $goldPrice->high;
        $low = (float) $goldPrice->low;
        $close = (float) $goldPrice->close;

        // =====================================================
        // PIVOT POINT
        // =====================================================

        // Pivot Point = (High + Low + Close) / 3
        $pp = ($high + $low + $close) / 3;

        // Range = High - Low
        $range = $high - $low;

        // =====================================================
        // RESISTANCE
        // =====================================================

        // R1 = 2 × Pivot - Low
        $r1 = (2 * $pp) - $low;

        // R2 = Pivot + Range
        $r2 = $pp + $range;

        // R3 = Pivot + Range × 2
        $r3 = $pp + ($range * 2);

        // R4 = Pivot + Range × 3
        $r4 = $pp + ($range * 3);

        // =====================================================
        // SUPPORT
        // =====================================================

        // S1 = 2 × Pivot - High
        $s1 = (2 * $pp) - $high;

        // S2 = Pivot - Range
        $s2 = $pp - $range;

        // S3 = Pivot - Range × 2
        $s3 = $pp - ($range * 2);

        // S4 = Pivot - Range × 3
        $s4 = $pp - ($range * 3);

        // =====================================================
        // BUY / SELL / NEST
        // =====================================================

        $buy = $r1;
        $sell = $s1;

        // NEST = titik tengah antara S1 dan R1
        $nest = ($s1 + $r1) / 2;

        // =====================================================
        // UNIT
        // =====================================================

        $unit = $commodity === 'HSI'
            ? 'INDEX'
            : 'USD / t.oz';

        // =====================================================
        // RESPONSE
        // =====================================================

        return response()->json([
            'success' => true,
            'message' => 'Data pivot point berhasil diambil.',

            'data' => [
                'commodity' => $commodity,

                'date' => $goldPrice->recorded_at?->format('Y-m-d'),

                // Data sumber OHLC
                'source' => [
                    'open' => $open,
                    'high' => $high,
                    'low' => $low,
                    'close' => $close,
                ],

                // Pivot
                'pivot' => round($pp, 2),

                // Buy / Sell
                'buy' => round($buy, 2),
                'sell' => round($sell, 2),

                // Range
                'range' => round($range, 2),

                // Resistance
                'resistance' => [
                    'r1' => round($r1, 2),
                    'r2' => round($r2, 2),
                    'r3' => round($r3, 2),
                    'r4' => round($r4, 2),
                ],

                // Support
                'support' => [
                    's1' => round($s1, 2),
                    's2' => round($s2, 2),
                    's3' => round($s3, 2),
                    's4' => round($s4, 2),
                ],

                // Nest
                'nest' => round($nest, 2),

                // Unit
                'unit' => $unit,
            ],
        ]);
    }
}