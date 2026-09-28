<?php

$url = "https://www.newsmaker.id/id/tools/historical-data";

$data = file_get_contents($url);

$keyword = "2026-09-21";

$position = strpos($data, $keyword);

if ($position === false) {
    echo "Tanggal 2026-09-21 tidak ditemukan." . PHP_EOL;
    exit;
}

echo "POSISI TANGGAL: " . $position . PHP_EOL;
echo PHP_EOL;
echo "POTONGAN DATA:" . PHP_EOL;
echo substr($data, $position - 1500, 5000) . PHP_EOL;