<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class AuthController extends BaseController
{
    // ─────────────────────────────────────────────────────────────
    //  CORS Helper – dipanggil di setiap method
    // ─────────────────────────────────────────────────────────────
    private function setCorsHeaders(): void
    {
        $this->response->setHeader('Access-Control-Allow-Origin', '*');
        $this->response->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $this->response->setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $this->response->setHeader('Access-Control-Allow-Credentials', 'true');
    }

    // ─────────────────────────────────────────────────────────────
    //  OPTIONS preflight handler (dipanggil dari Routes)
    // ─────────────────────────────────────────────────────────────
    public function options(): ResponseInterface
    {
        $this->setCorsHeaders();
        return $this->response->setStatusCode(200)->setBody('');
    }

    // ─────────────────────────────────────────────────────────────
    //  POST /api/register
    // ─────────────────────────────────────────────────────────────
    public function register(): ResponseInterface
    {
        $this->setCorsHeaders();

        // Ambil body JSON
        $json = $this->request->getJSON(true);

        // Validasi field wajib
        $nim      = trim($json['nim']      ?? '');
        $name     = trim($json['name']     ?? '');
        $password = trim($json['password'] ?? '');
        $semester = $json['semester']      ?? null;
        $gender   = trim($json['gender']   ?? '');

        if (empty($nim) || empty($name) || empty($password) || empty($semester) || empty($gender)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Semua field (nim, name, password, semester, gender) wajib diisi.',
                ]);
        }

        // Validasi gender
        if (!in_array(strtolower($gender), ['male', 'female', 'laki-laki', 'perempuan'])) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Nilai gender tidak valid. Gunakan: male / female / laki-laki / perempuan.',
                ]);
        }

        $model = new UserModel();

        // Cek NIM duplikat
        if ($model->findByNim($nim)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_CONFLICT)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'NIM sudah terdaftar.',
                ]);
        }

        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        // Simpan ke database
        $userId = $model->insert([
            'nim'      => $nim,
            'name'     => $name,
            'password' => $hashedPassword,
            'semester' => (int) $semester,
            'gender'   => strtolower($gender),
            'role'     => 'user',
        ]);

        if (!$userId) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Registrasi gagal. Silakan coba lagi.',
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_CREATED)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Registrasi berhasil.',
                'data'    => [
                    'id'       => $userId,
                    'nim'      => $nim,
                    'name'     => $name,
                    'semester' => (int) $semester,
                    'gender'   => strtolower($gender),
                    'role'     => 'user',
                ],
            ]);
    }

    // ─────────────────────────────────────────────────────────────
    //  POST /api/login
    // ─────────────────────────────────────────────────────────────
    public function login(): ResponseInterface
    {
        $this->setCorsHeaders();

        // Ambil body JSON
        $json = $this->request->getJSON(true);

        $nim      = trim($json['nim']      ?? '');
        $password = trim($json['password'] ?? '');

        if (empty($nim) || empty($password)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'NIM dan password wajib diisi.',
                ]);
        }

        $model = new UserModel();
        $user  = $model->findByNim($nim);

        // Cek user & verifikasi password
        if (!$user || !password_verify($password, $user['password'])) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_UNAUTHORIZED)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'NIM atau password salah.',
                ]);
        }

        // Hapus password dari response
        unset($user['password']);

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Login berhasil.',
                'data'    => $user,
            ]);
    }
}
