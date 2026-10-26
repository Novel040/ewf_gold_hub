<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GoldPrice;
use Illuminate\Http\Request;

class PivotPointController extends Controller
{
    public function index(Request $request)
    {
        $commodity = strtoupper(
            $request->query('commodity', 'LGD')
        );

        if (!in_array($commodity, ['LGD', 'HSI'])) {
            return response()->json([
                'success' => false,
                'message' => 'Commodity harus LGD atau HSI.',
                'data' => null,
            ], 400);
        }

        $price = GoldPrice::where('commodity', $commodity)
            ->orderByDesc('recorded_at')
            ->first();

        if (!$price) {
            return response()->json([
                'success' => false,
                'message' => "Data harga {$commodity} belum tersedia.",
                'data' => null,
            ], 404);
        }

        $high = (float) $price->high;
        $low = (float) $price->low;
        $close = (float) $price->close;

        $pivot = ($high + $low + $close) / 3;
        $range = $high - $low;

        $r1 = (2 * $pivot) - $low;
        $r2 = $pivot + $range;
        $r3 = $pivot + (2 * $range);
        $r4 = $pivot + (3 * $range);

        $s1 = (2 * $pivot) - $high;
        $s2 = $pivot - $range;
        $s3 = $pivot - (2 * $range);
        $s4 = $pivot - (3 * $range);

        return response()->json([
            'success' => true,
            'message' => 'Data Pivot Point berhasil diambil.',
            'data' => [
                'commodity' => $commodity,
                'date' => $price->recorded_at?->format('Y-m-d'),
                'source' => [
                    'open' => (float) $price->open,
                    'high' => $high,
                    'low' => $low,
                    'close' => $close,
                ],
                'pivot' => round($pivot, 2),
                'buy' => round($r1, 2),
                'sell' => round($s1, 2),
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
                'nest' => round(($s1 + $r1) / 2, 2),
                'unit' => $commodity === 'HSI'
                    ? 'INDEX'
                    : 'USD / t.oz',
            ],
        ]);
    }
}
