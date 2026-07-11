<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use App\Models\ChatModel;
use CodeIgniter\HTTP\ResponseInterface;

class ChatController extends BaseController
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
    //  GET /api/chat/{senderId}/{receiverId}
    //  Mengambil semua chat antara dua user
    // ─────────────────────────────────────────────────────────────
    public function getMessages($myId, $friendId)
    {
        $this->setCorsHeaders();

        $chatModel = new ChatModel();

        // 1. Memilih kolom secara spesifik agar JSON menyertakan id, sender_id, message, dan created_at
        $chatModel->select('id, sender_id, receiver_id, message, is_read, created_at');

        // 2. Setup kondisi WHERE (sender_id = $myId AND receiver_id = $friendId) OR (sender_id = $friendId AND receiver_id = $myId)
        $chatModel->groupStart()
                    ->where('sender_id', $myId)
                    ->where('receiver_id', $friendId)
                ->groupEnd()
                ->orGroupStart()
                    ->where('sender_id', $friendId)
                    ->where('receiver_id', $myId)
                ->groupEnd();

        // 3. Tambahkan kondisi last_id opsional jika ada (optimasi request)
        $lastId = $this->request->getVar('last_id');
        if (!empty($lastId) && is_numeric($lastId)) {
            $chatModel->where('id >', $lastId);
        }

        // 4. Urutkan berdasarkan id ASC (id auto-increment = kronologis)
        $messages = $chatModel->orderBy('id', 'ASC')->findAll();

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Berhasil mengambil pesan',
                'data'    => $messages,
            ]);
    }

    // ─────────────────────────────────────────────────────────────
    //  POST /api/chat/send
    //  Mengirim pesan baru
    // ─────────────────────────────────────────────────────────────
    public function sendMessage()
    {
        $this->setCorsHeaders();

        $json = $this->request->getJSON(true);

        $senderId   = $json['sender_id']   ?? null;
        $receiverId = $json['receiver_id'] ?? null;
        $message    = $json['message']     ?? '';

        if (empty($senderId) || empty($receiverId) || trim($message) === '') {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'sender_id, receiver_id, dan message wajib diisi.',
                ]);
        }

        $chatModel = new ChatModel();

        $data = [
            'sender_id'   => $senderId,
            'receiver_id' => $receiverId,
            'message'     => $message,
            'created_at'  => gmdate('Y-m-d H:i:s'),
        ];

        $inserted = $chatModel->insert($data);

        if (!$inserted) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal mengirim pesan.',
                ]);
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_CREATED)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Pesan berhasil dikirim.',
                'data'    => array_merge($data, ['id' => $inserted]),
            ]);
    }

    // ─────────────────────────────────────────────────────────────
    //  POST /api/chat/read/{myId}/{friendId}
    //  Menandai pesan dari teman sebagai sudah dibaca
    // ─────────────────────────────────────────────────────────────
    public function readMessages($myId, $friendId)
    {
        $this->setCorsHeaders();

        $chatModel = new ChatModel();

        // Update semua pesan di mana pengirim adalah teman dan penerima adalah saya
        $chatModel->where('sender_id', $friendId)
                  ->where('receiver_id', $myId)
                  ->where('is_read', 0)
                  ->set(['is_read' => 1])
                  ->update();

        return $this->response->setJSON([
            'status'  => 'success',
            'message' => 'Pesan telah dibaca',
        ]);
    }
}
