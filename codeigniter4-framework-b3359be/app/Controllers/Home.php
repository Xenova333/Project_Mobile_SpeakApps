<?php
namespace App\Controllers;


class Home extends BaseController
{
    public function index()
    {
        // Kita beri respons teks supaya browser HP tidak kosong
        return "Halo! Server CodeIgniter 4 berhasil terhubung ke HP Oppo kamu.";
    }

    public function test_api()
    {
        // Ini untuk tes JSON (format yang dibaca Flutter)
        return $this->response->setJSON([
            'status' => 'success',
            'message' => 'Koneksi API Berhasil!'
        ]);
    }
}