<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class NewsController extends Controller
{
    public function index(Request $request)
    {
        try {
            $perPage = min(
                max((int) $request->query('per_page', 20), 1),
                50
            );

            $response = Http::timeout(15)->get(
                'https://www.equityworld-futures.com/api/portalnews',
                [
                    'page' => max((int) $request->query('page', 1), 1),
                    'per_page' => $perPage,
                    'sort_by' => 'created_at',
                    'order' => 'desc',
                ]
            );

            if (! $response->successful()) {
                return response()->json([
                    'message' => 'Gagal mengambil berita dari sumber resmi.',
                ], 502);
            }

            $payload = $response->json();

            $news = collect($payload['data'] ?? [])->map(function ($item) {
                $slug = $item['slug'] ?? '';

                return [
                    'id' => $item['id'] ?? null,
                    'title' => $item['titles']['ewf']
                        ?? $item['title']
                        ?? '',
                    'content' => $item['content'] ?? '',
                    'category' => $item['category']
                        ?? $item['kategori']['name']
                        ?? 'Berita',
                    'source' => 'Equityworld Futures',
                    'image' => $item['image']
                        ?? ($item['images'][0] ?? ''),
                    'published_at' => $item['created_at'] ?? null,
                    'slug' => $slug,
                    'url' => $item['link'] ?? '',
                ];
            })->values();

            return response()->json($news);
        } catch (\Throwable $e) {
            report($e);

            return response()->json([
                'message' => 'Terjadi kesalahan saat mengambil berita.',
            ], 500);
        }
    }
}