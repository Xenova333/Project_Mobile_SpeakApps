<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class UserController extends BaseController
{
    // ─────────────────────────────────────────────────────────────────────
    //  CORS Helper — dipanggil di setiap method publik
    // ─────────────────────────────────────────────────────────────────────

    private function setCorsHeaders(): void
    {
        $this->response->setHeader('Access-Control-Allow-Origin', '*');
        $this->response->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $this->response->setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $this->response->setHeader('Access-Control-Allow-Credentials', 'true');
    }

    // ─────────────────────────────────────────────────────────────────────
    //  Konstanta path upload foto profil (absolut via FCPATH)
    //  FCPATH = path ke folder /public tempat index.php berada
    //  Contoh Windows: D:\Project\...\public\uploads\profile\
    // ─────────────────────────────────────────────────────────────────────

    private function uploadPath(): string
    {
        return FCPATH . 'uploads' . DIRECTORY_SEPARATOR . 'profile' . DIRECTORY_SEPARATOR;
    }

    // ─────────────────────────────────────────────────────────────────────
    //  POST  /api/user/update/{userId}
    //
    //  Memperbarui profil user: name, semester, gender, dan profile_pic.
    //  NIM tidak dapat diubah — dijaga read-only di Flutter maupun di sini.
    // ─────────────────────────────────────────────────────────────────────

    public function updateProfile(int $userId): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new UserModel();

        // ── 1. Pastikan user dengan ID ini ada di database ──────────────
        $existingUser = $model->find($userId);
        if (! $existingUser) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "User dengan ID {$userId} tidak ditemukan.",
                ]);
        }

        // ── 2. Ambil field teks dari multipart/form-data ─────────────────
        $name     = trim($this->request->getPost('name')     ?? '');
        $semester = trim($this->request->getPost('semester') ?? '');
        $gender   = trim(strtolower($this->request->getPost('gender') ?? ''));

        // ── 3. Validasi field teks wajib ─────────────────────────────────
        if (empty($name)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "name" wajib diisi dan tidak boleh kosong.',
                ]);
        }

        if (empty($semester) || ! is_numeric($semester)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "semester" wajib diisi dan harus berupa angka.',
                ]);
        }

        $semesterInt = (int) $semester;
        if ($semesterInt < 1 || $semesterInt > 14) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Semester tidak valid. Masukkan angka antara 1 hingga 14.',
                ]);
        }

        $validGenders = ['male', 'female', 'laki-laki', 'perempuan'];
        if (empty($gender) || ! in_array($gender, $validGenders)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Nilai gender tidak valid. Gunakan: male / female / laki-laki / perempuan.',
                ]);
        }

        // ── 4. Proses Upload Foto Profil ─────────────────────────────────
        // Default: pertahankan foto lama jika tidak ada file baru dikirim
        $profilePicName = $existingUser['profile_pic'] ?? null;

        $file = $this->request->getFile('profile_pic');

        if ($file !== null && $file->isValid() && ! $file->hasMoved()) {
            // ── 4a. Validasi ukuran file — maks 5 MB (5120 KB) ───────────
            // imageQuality:30 di Flutter menghasilkan ~30–100 KB.
            // Batas 5120 KB (5 MB) cukup longgar untuk mencegah false rejection.
            $fileSizeKB = $file->getSizeByUnit('kb');
            if ($fileSizeKB > 5120) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Foto terlalu besar ({$fileSizeKB} KB). Maksimal 5120 KB (5 MB).",
                    ]);
            }

            // ── 4b. Validasi tipe file (ekstensi + MIME) ──────────────────
            // getMimeType() memakai deteksi konten aktual (lebih andal dari header klien).
            // getClientExtension() sebagai konfirmasi tambahan.
            $allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/pjpeg'];
            $allowedExts  = ['jpg', 'jpeg', 'png'];

            $mimeType  = $file->getMimeType();
            $clientExt = strtolower($file->getClientExtension());

            // Fallback jika getClientExtension() kosong (terjadi di beberapa versi Android)
            if (empty($clientExt)) {
                $clientExt = strtolower($file->getExtension());
            }

            if (! in_array($mimeType, $allowedMimes) || ! in_array($clientExt, $allowedExts)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        // Sertakan nilai aktual agar Flutter bisa debug di SnackBar
                        'message' => "Format foto tidak valid. "
                            . "Ekstensi yang diterima: jpg, jpeg, png. "
                            . "Diterima ext={$clientExt}, mime={$mimeType}.",
                    ]);
            }

            // ── 4c. Siapkan direktori upload ──────────────────────────────
            $uploadPath = $this->uploadPath();

            if (! is_dir($uploadPath)) {
                if (! mkdir($uploadPath, 0755, true)) {
                    return $this->response
                        ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                        ->setJSON([
                            'status'  => 'error',
                            'message' => 'Gagal membuat direktori upload. Periksa permission folder di server.',
                        ]);
                }
            }

            if (! is_writable($uploadPath)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Direktori upload tidak dapat ditulis: {$uploadPath}",
                    ]);
            }

            // ── 4d. Hapus foto lama agar folder tidak menumpuk ───────────
            $oldPic = $existingUser['profile_pic'] ?? '';
            if (
                ! empty($oldPic)
                && $oldPic !== 'default.png'
                && strpos($oldPic, '..') === false  // cegah path traversal
            ) {
                $oldFilePath = $uploadPath . $oldPic;
                if (file_exists($oldFilePath)) {
                    unlink($oldFilePath);
                }
            }

            // ── 4e. Pindahkan file baru dengan nama acak ──────────────────
            $newFileName = $file->getRandomName();

            try {
                $file->move($uploadPath, $newFileName);
            } catch (\Exception $e) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => 'Gagal memindahkan file upload: ' . $e->getMessage(),
                    ]);
            }

            // Verifikasi file benar-benar ada setelah move()
            if (! file_exists($uploadPath . $newFileName)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => 'File berhasil diproses namun tidak ditemukan setelah disimpan. Coba lagi.',
                    ]);
            }

            $profilePicName = $newFileName;

        } elseif ($file !== null && ! $file->isValid()) {
            // File dikirim tapi ditolak sistem (rusak, ukuran 0, dll.)
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'File yang dikirim tidak valid: ' . $file->getErrorString(),
                ]);
        }
        // Jika $file === null → tidak ada file dikirim → lanjut hanya update teks

        // ── 5. Simpan perubahan ke database ──────────────────────────────
        $updateData = [
            'name'        => $name,
            'semester'    => $semesterInt,
            'gender'      => $gender,
            'profile_pic' => $profilePicName,
        ];

        $updated = $model->update($userId, $updateData);

        if (! $updated) {
            $modelErrors = $model->errors();
            $errDetail   = ! empty($modelErrors)
                ? implode('; ', $modelErrors)
                : 'Tidak ada detail error dari model.';

            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal update ke database: ' . $errDetail,
                ]);
        }

        // ── 6. Kembalikan data user terbaru (tanpa password) ─────────────
        $updatedUser = $model->find($userId);
        if (isset($updatedUser['password'])) {
            unset($updatedUser['password']);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Profil berhasil diperbarui.',
                'data'    => $updatedUser,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  GET  /api/user/{userId}
    //  Ambil data profil user berdasarkan ID (tanpa password)
    // ─────────────────────────────────────────────────────────────────────

    public function getProfile(int $userId): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new UserModel();
        $user  = $model->find($userId);

        if (! $user) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "User dengan ID {$userId} tidak ditemukan.",
                ]);
        }

        if (isset($user['password'])) {
            unset($user['password']);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status' => 'success',
                'data'   => $user,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  POST  /api/admin/reset-password
    //  Reset password user (mahasiswa) oleh admin berdasarkan NIM
    // ─────────────────────────────────────────────────────────────────────

    public function adminResetPassword(): ResponseInterface
    {
        $this->setCorsHeaders();

        $nim = trim($this->request->getPost('nim') ?? '');
        $newPassword = trim($this->request->getPost('new_password') ?? '');

        if (empty($nim) || empty($newPassword)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'NIM dan Password baru wajib diisi.',
                ]);
        }

        $model = new UserModel();
        $user = $model->where('nim', $nim)->first();

        if (! $user) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "User dengan NIM {$nim} tidak ditemukan.",
                ]);
        }

        $hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
        $updated = $model->update($user['id'], ['password' => $hashedPassword]);

        if (! $updated) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal mengubah password.',
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 200,
                'message' => 'Password berhasil direset'
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  DELETE  /api/user/{userId}
    //  Hapus akun user beserta semua data terkait (chat, friends, profile pic)
    // ─────────────────────────────────────────────────────────────────────

    public function deleteUser(int $userId): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new UserModel();
        $user = $model->find($userId);

        if (! $user) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "User dengan ID {$userId} tidak ditemukan.",
                ]);
        }

        $db = \Config\Database::connect();

        // Hapus profile pic kecuali default
        $profilePic = $user['profile_pic'] ?? '';
        if (! empty($profilePic) && $profilePic !== 'default.png' && strpos($profilePic, '..') === false) {
            $picPath = FCPATH . 'uploads' . DIRECTORY_SEPARATOR . 'profile' . DIRECTORY_SEPARATOR . $profilePic;
            if (file_exists($picPath)) {
                unlink($picPath);
            }
        }

        // Hapus data chat terkait
        $db->query("DELETE FROM chats WHERE sender_id = ? OR receiver_id = ?", [$userId, $userId]);

        // Hapus data friends terkait
        $db->query("DELETE FROM friends WHERE user_id = ? OR friend_id = ?", [$userId, $userId]);

        // Hapus user
        $deleted = $model->delete($userId);

        if (! $deleted) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal menghapus akun.',
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Akun berhasil dihapus.',
            ]);
    }
}
