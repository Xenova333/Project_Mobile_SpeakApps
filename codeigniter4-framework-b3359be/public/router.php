<?php

/**
 * router.php — PHP Built-in Server Router (CORS-aware)
 *
 * Jalankan dengan:
 *   php -S 0.0.0.0:8080 -t public public/router.php
 *
 * PENTING: Jangan gunakan `return false` untuk file statis!
 * Ketika router.php mengembalikan false, PHP built-in server melayani
 * file tersebut sendiri dan MEMBUANG semua header yang sudah di-set PHP,
 * termasuk Access-Control-Allow-Origin. Akibatnya CORS tetap gagal.
 *
 * Solusi: layani file statis secara manual via readfile() setelah
 * header CORS terpasang.
 */

// ── 1. Pasang CORS header ke SEMUA response ───────────────────────────────
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-API-KEY');

// ── 2. Tangani preflight OPTIONS request ──────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ── 3. Cek apakah request menuju file statis yang ada di disk ─────────────
$requestUri  = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$filePath    = __DIR__ . $requestUri;

if (is_file($filePath)) {
    // ── 3a. Tentukan MIME type berdasarkan ekstensi ───────────────────────
    $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
    $mimeTypes = [
        'jpg'  => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'png'  => 'image/png',
        'gif'  => 'image/gif',
        'webp' => 'image/webp',
        'svg'  => 'image/svg+xml',
        'ico'  => 'image/x-icon',
        'css'  => 'text/css',
        'js'   => 'application/javascript',
        'txt'  => 'text/plain',
        'json' => 'application/json',
        'woff' => 'font/woff',
        'woff2'=> 'font/woff2',
    ];

    $mime = $mimeTypes[$ext] ?? 'application/octet-stream';
    header('Content-Type: ' . $mime);
    header('Content-Length: ' . filesize($filePath));

    // ── 3b. Kirim isi file — CORS header sudah terpasang di atas ─────────
    // JANGAN return false di sini karena PHP akan membuang semua header.
    readfile($filePath);
    exit();
}

// ── 4. Bukan file statis → teruskan ke CodeIgniter (index.php) ───────────
require __DIR__ . '/index.php';
