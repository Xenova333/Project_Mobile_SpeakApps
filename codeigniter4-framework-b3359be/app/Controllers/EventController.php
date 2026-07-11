<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;

class EventController extends BaseController
{
    // ─────────────────────────────────────────────────────────────────────
    //  CORS Helper
    // ─────────────────────────────────────────────────────────────────────

    private function setCorsHeaders(): void
    {
        $this->response->setHeader('Access-Control-Allow-Origin', '*');
        $this->response->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $this->response->setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $this->response->setHeader('Access-Control-Allow-Credentials', 'true');
    }

    // ─────────────────────────────────────────────────────────────────────
    //  Upload path untuk gambar event
    // ─────────────────────────────────────────────────────────────────────

    private function uploadPath(): string
    {
        return FCPATH . 'uploads' . DIRECTORY_SEPARATOR . 'events' . DIRECTORY_SEPARATOR;
    }

    // ─────────────────────────────────────────────────────────────────────
    //  GET  /api/events
    //  Ambil semua event, urutkan dari yang terbaru
    // ─────────────────────────────────────────────────────────────────────

    public function index(): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new EventModel();
        $events = $model->orderBy('id', 'DESC')->findAll();

        $uploadPath = $this->uploadPath();
        $needsUpdate = false;
        foreach ($events as &$event) {
            if (! empty($event['image']) && ! file_exists($uploadPath . $event['image'])) {
                $model->update($event['id'], ['image' => null]);
                $event['image'] = null;
                $needsUpdate = true;
            }
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status' => 'success',
                'data'   => $events,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  GET  /api/events/{id}
    //  Ambil detail event berdasarkan ID
    // ─────────────────────────────────────────────────────────────────────

    public function show(int $id): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new EventModel();
        $event = $model->find($id);

        if (! $event) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "Event dengan ID {$id} tidak ditemukan.",
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status' => 'success',
                'data'   => $event,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  POST  /api/events
    //  Buat event baru (admin only) — multipart/form-data
    // ─────────────────────────────────────────────────────────────────────

    public function create(): ResponseInterface
    {
        $this->setCorsHeaders();

        // ── 1. Validasi admin ────────────────────────────────────────
        $createdBy = $this->request->getPost('created_by');
        if (empty($createdBy)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "created_by" wajib diisi.',
                ]);
        }

        $userModel = new UserModel();
        $adminUser = $userModel->find((int) $createdBy);

        if (! $adminUser || ($adminUser['role'] ?? '') !== 'admin') {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_FORBIDDEN)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Hanya admin yang dapat membuat event.',
                ]);
        }

        // ── 2. Ambil field teks ──────────────────────────────────────
        $title       = trim($this->request->getPost('title') ?? '');
        $description = trim($this->request->getPost('description') ?? '');
        $eventDate   = trim($this->request->getPost('event_date') ?? '');
        $eventLink   = trim($this->request->getPost('event_link') ?? '');

        // ── 3. Validasi ──────────────────────────────────────────────
        if (empty($title)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "title" wajib diisi.',
                ]);
        }

        if (empty($eventDate)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "event_date" wajib diisi.',
                ]);
        }

        // ── 4. Proses Upload Gambar (opsional) ───────────────────────
        $imageName = null;
        $file = $this->request->getFile('image');

        if ($file !== null && $file->isValid() && ! $file->hasMoved()) {
            $fileSizeKB = $file->getSizeByUnit('kb');
            if ($fileSizeKB > 5120) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Gambar terlalu besar ({$fileSizeKB} KB). Maksimal 5120 KB (5 MB).",
                    ]);
            }

            $allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/pjpeg'];
            $allowedExts  = ['jpg', 'jpeg', 'png'];

            $mimeType  = $file->getMimeType();
            $clientExt = strtolower($file->getClientExtension());

            if (empty($clientExt)) {
                $clientExt = strtolower($file->getExtension());
            }

            if (! in_array($mimeType, $allowedMimes) || ! in_array($clientExt, $allowedExts)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Format gambar tidak valid. Ekstensi yang diterima: jpg, jpeg, png. Diterima ext={$clientExt}, mime={$mimeType}.",
                    ]);
            }

            $uploadPath = $this->uploadPath();

            if (! is_dir($uploadPath)) {
                if (! mkdir($uploadPath, 0755, true)) {
                    return $this->response
                        ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                        ->setJSON([
                            'status'  => 'error',
                            'message' => 'Gagal membuat direktori upload.',
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

            $imageName = $newFileName;
        } elseif ($file !== null && ! $file->isValid()) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'File yang dikirim tidak valid: ' . $file->getErrorString(),
                ]);
        }

        // ── 5. Simpan ke database ────────────────────────────────────
        $model = new EventModel();

        $insertData = [
            'title'       => $title,
            'description' => $description,
            'image'       => $imageName,
            'event_date'  => $eventDate,
            'event_link'  => $eventLink,
            'created_by'  => (int) $createdBy,
        ];

        $insertedId = $model->insert($insertData);

        if (! $insertedId) {
            $modelErrors = $model->errors();
            $errDetail   = ! empty($modelErrors) ? implode('; ', $modelErrors) : 'Tidak ada detail error.';

            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal menyimpan event: ' . $errDetail,
                ]);
        }

        $newEvent = $model->find($insertedId);

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_CREATED)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Event berhasil dibuat.',
                'data'    => $newEvent,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  POST  /api/events/update/{id}
    //  Update event (admin only) — multipart/form-data
    // ─────────────────────────────────────────────────────────────────────

    public function update(int $id): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new EventModel();
        $existingEvent = $model->find($id);

        if (! $existingEvent) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "Event dengan ID {$id} tidak ditemukan.",
                ]);
        }

        // ── Ambil field teks ─────────────────────────────────────────
        $title       = trim($this->request->getPost('title') ?? $existingEvent['title']);
        $description = trim($this->request->getPost('description') ?? $existingEvent['description']);
        $eventDate   = trim($this->request->getPost('event_date') ?? $existingEvent['event_date']);
        $eventLink   = trim($this->request->getPost('event_link') ?? $existingEvent['event_link']);

        if (empty($title)) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Field "title" wajib diisi.',
                ]);
        }

        // ── Proses Upload Gambar baru (opsional) ─────────────────────
        $imageName = $existingEvent['image'];
        $file = $this->request->getFile('image');

        if ($file !== null && $file->isValid() && ! $file->hasMoved()) {
            $fileSizeKB = $file->getSizeByUnit('kb');
            if ($fileSizeKB > 5120) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Gambar terlalu besar ({$fileSizeKB} KB). Maksimal 5120 KB (5 MB).",
                    ]);
            }

            $allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/pjpeg'];
            $allowedExts  = ['jpg', 'jpeg', 'png'];

            $mimeType  = $file->getMimeType();
            $clientExt = strtolower($file->getClientExtension());

            if (empty($clientExt)) {
                $clientExt = strtolower($file->getExtension());
            }

            if (! in_array($mimeType, $allowedMimes) || ! in_array($clientExt, $allowedExts)) {
                return $this->response
                    ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                    ->setJSON([
                        'status'  => 'error',
                        'message' => "Format gambar tidak valid. Ekstensi yang diterima: jpg, jpeg, png. Diterima ext={$clientExt}, mime={$mimeType}.",
                    ]);
            }

            $uploadPath = $this->uploadPath();

            if (! is_dir($uploadPath)) {
                mkdir($uploadPath, 0755, true);
            }

            // Hapus gambar lama
            $oldImage = $existingEvent['image'] ?? '';
            if (! empty($oldImage) && strpos($oldImage, '..') === false) {
                $oldFilePath = $uploadPath . $oldImage;
                if (file_exists($oldFilePath)) {
                    unlink($oldFilePath);
                }
            }

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

            $imageName = $newFileName;
        }

        // ── Update database ──────────────────────────────────────────
        $updateData = [
            'title'       => $title,
            'description' => $description,
            'image'       => $imageName,
            'event_date'  => $eventDate,
            'event_link'  => $eventLink,
        ];

        $updated = $model->update($id, $updateData);

        if (! $updated) {
            $modelErrors = $model->errors();
            $errDetail   = ! empty($modelErrors) ? implode('; ', $modelErrors) : 'Tidak ada detail error.';

            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal update event: ' . $errDetail,
                ]);
        }

        $updatedEvent = $model->find($id);

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Event berhasil diperbarui.',
                'data'    => $updatedEvent,
            ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  DELETE  /api/events/{id}
    //  Hapus event (admin only)
    // ─────────────────────────────────────────────────────────────────────

    public function delete(int $id): ResponseInterface
    {
        $this->setCorsHeaders();

        $model = new EventModel();
        $event = $model->find($id);

        if (! $event) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_NOT_FOUND)
                ->setJSON([
                    'status'  => 'error',
                    'message' => "Event dengan ID {$id} tidak ditemukan.",
                ]);
        }

        // Hapus gambar terkait
        $imageName = $event['image'] ?? '';
        if (! empty($imageName) && strpos($imageName, '..') === false) {
            $filePath = $this->uploadPath() . $imageName;
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }

        $deleted = $model->delete($id);

        if (! $deleted) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal menghapus event.',
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Event berhasil dihapus.',
            ]);
    }
}
