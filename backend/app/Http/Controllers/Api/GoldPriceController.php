<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GoldPrice;

class GoldPriceController extends Controller
{
    public function index()
    {
        $prices = GoldPrice::orderBy('recorded_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data harga emas berhasil diambil',
            'data' => $prices,
        ]);
    }

    public function latest()
    {
        $price = GoldPrice::orderBy('recorded_at', 'desc')->first();

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