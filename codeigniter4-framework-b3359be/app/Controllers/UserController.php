<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class UserController extends BaseController
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
    //  POST /api/user/update/:id
    //  Update profile user (name, semester, gender, profile_pic)
    //  NIM tidak dapat diubah
    // ─────────────────────────────────────────────────────────────
    public function updateProfile(int $userId): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new UserModel();

        // Cek apakah user dengan ID tersebut ada
        $existingUser = $model->find($userId);
        if (!$existingUser) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'User tidak ditemukan.',
                ]);
        }

        // Ambil data dari form-data (multipart/form-data)
        $name     = trim($this->request->getPost('name')     ?? '');
        $semester = $this->request->getPost('semester')      ?? null;
        $gender   = trim($this->request->getPost('gender')   ?? '');

        // Validasi field wajib
        if (empty($name) || empty($semester) || empty($gender)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field name, semester, dan gender wajib diisi.',
                ]);
        }

        // Validasi nilai semester
        if (!is_numeric($semester) || (int) $semester < 1 || (int) $semester > 14) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Semester tidak valid. Masukkan angka antara 1 hingga 14.',
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

        // ── Proses Upload Foto Profile ────────────────────────────
        $profilePicName = $existingUser['profile_pic']; // gunakan foto lama jika tidak ada unggahan baru

        $uploadedFile = $this->request->getFile('profile_pic');

        if ($uploadedFile !== null && $uploadedFile->isValid() && !$uploadedFile->hasMoved()) {

            // Validasi ukuran file (maks 2MB = 2048 KB)
            if ($uploadedFile->getSizeByUnit('kb') > 2048) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => 'Ukuran foto profil tidak boleh melebihi 2MB.',
                    ]);
            }

            // Validasi format/ekstensi file
            $allowedTypes = ['image/png', 'image/jpg', 'image/jpeg'];
            $allowedExts  = ['png', 'jpg', 'jpeg'];
            $mimeType     = $uploadedFile->getMimeType();
            $extension    = strtolower($uploadedFile->getClientExtension());

            if (!in_array($mimeType, $allowedTypes) || !in_array($extension, $allowedExts)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => 'Format foto tidak valid. Gunakan format: png, jpg, atau jpeg.',
                    ]);
            }

            // Hapus foto lama jika bukan default.png
            $uploadPath = FCPATH . 'uploads/profile/';
            if (
                !empty($existingUser['profile_pic']) &&
                $existingUser['profile_pic'] !== 'default.png'
            ) {
                $oldFilePath = $uploadPath . $existingUser['profile_pic'];
                if (file_exists($oldFilePath)) {
                    unlink($oldFilePath);
                }
            }

            // Pastikan folder upload tersedia
            if (!is_dir($uploadPath)) {
                mkdir($uploadPath, 0755, true);
            }

            // Simpan file baru dengan nama acak
            $newFileName = $uploadedFile->getRandomName();
            $uploadedFile->move($uploadPath, $newFileName);

            $profilePicName = $newFileName;
        }

        // ── Update ke Database ────────────────────────────────────
        $updateData = [
            'name'        => $name,
            'semester'    => (int) $semester,
            'gender'      => strtolower($gender),
            'profile_pic' => $profilePicName,
        ];

        $updated = $model->update($userId, $updateData);

        if (!$updated) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal memperbarui profil. Silakan coba lagi.',
                ]);
        }

        // Ambil data user terbaru (tanpa password)
        $updatedUser = $model->find($userId);
        unset($updatedUser['password']);

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Profil berhasil diperbarui.',
                'data'    => $updatedUser,
            ]);
    }
}
