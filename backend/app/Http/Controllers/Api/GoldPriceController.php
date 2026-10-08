<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GoldPrice;
use Illuminate\Http\Request;

class GoldPriceController extends Controller
{
    public function index(Request $request)
    {
        $query = GoldPrice::orderBy('recorded_at', 'desc');

        if ($request->has('commodity')) {
            $query->where(
                'commodity',
                strtoupper($request->query('commodity'))
            );
        }

        $prices = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Data harga emas berhasil diambil',
            'data' => $prices,
        ]);
    }

    public function latest(Request $request)
    {
        $query = GoldPrice::orderBy('recorded_at', 'desc');

        if ($request->has('commodity')) {
            $query->where(
                'commodity',
                strtoupper($request->query('commodity'))
            );
        }

        $price = $query->first();

        if (!$price) {
            return response()->json([
                'success' => false,
                'message' => 'Data harga emas belum tersedia',
                'data' => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data harga emas terbaru berhasil diambil',
            'data' => $price,
        ]);
    }
}