<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use App\Models\TemanModel;
use CodeIgniter\HTTP\ResponseInterface;

class TemanController extends BaseController
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

    public function getKontak(int $userId)
    {
        $this->setCorsHeaders();
        
        $db = \Config\Database::connect();

        // Mengambil teman (status = accepted) beserta pesan terakhir (subquery ke tabel chats)
        $sql = "
            SELECT 
                f.id,
                f.user_id,
                f.friend_id,
                f.status,
                f.created_at,
                u.name, 
                u.profile_pic, 
                u.nim,
                (
                    SELECT message 
                    FROM chats c 
                    WHERE (c.sender_id = $userId AND c.receiver_id = u.id) 
                       OR (c.sender_id = u.id AND c.receiver_id = $userId)
                    ORDER BY c.created_at DESC 
                    LIMIT 1
                ) as latest_message,
                (
                    SELECT created_at 
                    FROM chats c 
                    WHERE (c.sender_id = $userId AND c.receiver_id = u.id) 
                       OR (c.sender_id = u.id AND c.receiver_id = $userId)
                    ORDER BY c.created_at DESC 
                    LIMIT 1
                ) as latest_chat_time,
                (
                    SELECT COUNT(*)
                    FROM chats c
                    WHERE c.sender_id = u.id 
                      AND c.receiver_id = $userId 
                      AND c.is_read = 0
                ) as unread_count
            FROM friends f
            LEFT JOIN users u ON u.id = IF(f.user_id = $userId, f.friend_id, f.user_id)
            WHERE (f.user_id = $userId OR f.friend_id = $userId)
              AND f.status = 'accepted'
            ORDER BY latest_chat_time DESC, f.created_at DESC
        ";

        $query = $db->query($sql);
        $results = $query->getResultArray();

        // Jika belum ada pesan, set nilai default
        foreach ($results as &$row) {
            if (empty($row['latest_message'])) {
                $row['latest_message'] = 'Belum ada pesan';
            }
        }

        return $this->response
            ->setStatusCode(ResponseInterface::HTTP_OK)
            ->setJSON([
                'status'  => 'success',
                'message' => 'Berhasil mengambil kontak',
                'data'    => $results
            ]);
    }

    /**
     * Mengambil daftar teman yang sudah diterima (status = accepted)
     * Tanpa subquery pesan terakhir, fokus pada data user teman.
     */
    public function getAcceptedFriends(int $myId)
    {
        $this->setCorsHeaders();
        
        $db = \Config\Database::connect();

        $sql = "
            SELECT 
                f.id,
                f.user_id,
                f.friend_id,
                f.status,
                f.created_at,
                u.id as user_data_id,
                u.name, 
                u.profile_pic, 
                u.nim,
                u.semester,
                u.gender,
                u.role,
                (
                    SELECT message 
                    FROM chats c 
                    WHERE (c.sender_id = $myId AND c.receiver_id = u.id) 
                       OR (c.sender_id = u.id AND c.receiver_id = $myId)
                    ORDER BY c.created_at DESC 
                    LIMIT 1
                ) as latest_message,
                (
                    SELECT created_at 
                    FROM chats c 
                    WHERE (c.sender_id = $myId AND c.receiver_id = u.id) 
                       OR (c.sender_id = u.id AND c.receiver_id = $myId)
                    ORDER BY c.created_at DESC 
                    LIMIT 1
                ) as latest_chat_time,
                (
                    SELECT COUNT(*)
                    FROM chats c
                    WHERE c.sender_id = u.id 
                      AND c.receiver_id = $myId 
                      AND c.is_read = 0
                ) as unread_count
            FROM friends f
            JOIN users u ON u.id = IF(f.user_id = $myId, f.friend_id, f.user_id)
            WHERE (f.user_id = $myId OR f.friend_id = $myId)
              AND f.status = 'accepted'
              AND u.id != $myId
            ORDER BY latest_chat_time DESC, f.created_at DESC
        ";

        try {
            $query = $db->query($sql);
            $results = $query->getResultArray();

            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_OK)
                ->setJSON([
                    'status'  => 'success',
                    'message' => 'Berhasil mengambil daftar teman',
                    'data'    => $results
                ]);
        } catch (\Exception $e) {
            return $this->response
                ->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal mengambil daftar teman: ' . $e->getMessage()
                ]);
        }
    }

    public function addTeman()
    {
        $this->setCorsHeaders();

        $json = $this->request->getJSON();
        if (!$json || !isset($json->user_id) || !isset($json->friend_id)) {
            return $this->response->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status' => 'error',
                    'message' => 'Data tidak lengkap (user_id dan friend_id diperlukan)'
                ]);
        }

        $userId = $json->user_id;
        $friendId = $json->friend_id;

        if ($userId == $friendId) {
            return $this->response->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status' => 'error',
                    'message' => 'Tidak dapat menambahkan diri sendiri sebagai teman'
                ]);
        }

        $temanModel = new TemanModel();

        // Cek apakah mereka sudah berteman
        $cekBerteman = $temanModel->groupStart()
                                    ->where('user_id', $userId)
                                    ->where('friend_id', $friendId)
                                  ->groupEnd()
                                  ->orGroupStart()
                                    ->where('user_id', $friendId)
                                    ->where('friend_id', $userId)
                                  ->groupEnd()
                                  ->first();

        if ($cekBerteman) {
            return $this->response->setStatusCode(ResponseInterface::HTTP_BAD_REQUEST)
                ->setJSON([
                    'status' => 'error',
                    'message' => 'Sudah berteman'
                ]);
        }

        // Jika belum berteman, simpan data ke tabel teman
        $data = [
            'user_id' => $userId,
            'friend_id' => $friendId,
            'status' => 'accepted',
            'created_at' => date('Y-m-d H:i:s')
        ];

        if ($temanModel->insert($data)) {
            return $this->response->setStatusCode(ResponseInterface::HTTP_OK)
                ->setJSON([
                    'status' => 'success',
                    'message' => 'Teman berhasil ditambahkan'
                ]);
        } else {
            return $this->response->setStatusCode(ResponseInterface::HTTP_INTERNAL_SERVER_ERROR)
                ->setJSON([
                    'status' => 'error',
                    'message' => 'Gagal menyimpan data teman'
                ]);
        }
    }

    public function getIncomingRequests(int $myId)
    {
        $this->setCorsHeaders();
        $temanModel = new TemanModel();

        // Mengambil request masuk yang statusnya pending
        $requests = $temanModel->select('friends.*, users.name, users.profile_pic, users.nim')
            ->where('friends.friend_id', $myId)
            ->where('friends.status', 'pending')
            ->join('users', 'users.id = friends.user_id') // join ke user yang mengirim request
            ->findAll();

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $requests
        ]);
    }

    // Mengambil permintaan pertemanan yang SUDAH DIKIRIM oleh user (sebagai pengirim)
    public function getSentRequests(int $myId)
    {
        $this->setCorsHeaders();
        $temanModel = new TemanModel();

        // user_id = myId (pengirim), friend_id = target, status = pending
        $requests = $temanModel->select('friends.*, users.name, users.profile_pic, users.nim')
            ->where('friends.user_id', $myId)
            ->where('friends.status', 'pending')
            ->join('users', 'users.id = friends.friend_id') // join ke user yang menjadi target
            ->findAll();

        return $this->response->setJSON([
            'status' => 'success',
            'data'   => $requests
        ]);
    }

    public function addFriendByNim()
    {
        $this->setCorsHeaders();
        $json = $this->request->getJSON();

        if (!$json || !isset($json->user_id) || !isset($json->nim)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status' => 'error',
                'message' => 'Data tidak lengkap (user_id dan nim diperlukan)'
            ]);
        }

        $userId = $json->user_id;
        $nim = $json->nim;

        // Cari ID user berdasarkan NIM
        $userModel = new \App\Models\UserModel();
        $targetUser = $userModel->where('nim', $nim)->first();

        if (!$targetUser) {
            return $this->response->setStatusCode(404)->setJSON([
                'status' => 'error',
                'message' => 'User dengan NIM tersebut tidak ditemukan'
            ]);
        }

        $friendId = $targetUser['id'];

        if ($userId == $friendId) {
            return $this->response->setStatusCode(400)->setJSON([
                'status' => 'error',
                'message' => 'Tidak dapat menambahkan diri sendiri'
            ]);
        }

        $temanModel = new TemanModel();

        // Cek apakah sudah berteman atau request sudah ada
        $cekBerteman = $temanModel->groupStart()
                                    ->where('user_id', $userId)
                                    ->where('friend_id', $friendId)
                                  ->groupEnd()
                                  ->orGroupStart()
                                    ->where('user_id', $friendId)
                                    ->where('friend_id', $userId)
                                  ->groupEnd()
                                  ->first();

        if ($cekBerteman) {
            return $this->response->setStatusCode(400)->setJSON([
                'status' => 'error',
                'message' => 'Sudah berteman atau permintaan sudah dikirim'
            ]);
        }

        $data = [
            'user_id' => $userId,
            'friend_id' => $friendId,
            'status' => 'pending',
            'created_at' => date('Y-m-d H:i:s')
        ];

        if ($temanModel->insert($data)) {
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Permintaan pertemanan berhasil dikirim'
            ]);
        }

        return $this->response->setStatusCode(500)->setJSON([
            'status' => 'error',
            'message' => 'Gagal mengirim permintaan'
        ]);
    }

    public function updateStatus()
    {
        $this->setCorsHeaders();
        $json = $this->request->getJSON();

        if (!$json || !isset($json->request_id) || !isset($json->new_status)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status' => 'error',
                'message' => 'Data tidak lengkap (request_id dan new_status diperlukan)'
            ]);
        }

        $requestId = $json->request_id;
        $newStatus = $json->new_status;

        $temanModel = new TemanModel();
        
        if ($temanModel->update($requestId, ['status' => $newStatus])) {
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Status pertemanan berhasil diubah menjadi ' . $newStatus
            ]);
        }

        return $this->response->setStatusCode(500)->setJSON([
            'status' => 'error',
            'message' => 'Gagal mengubah status'
        ]);
    }

    public function searchMyFriends(int $userId, string $keyword)
    {
        $this->setCorsHeaders();
        
        $temanModel = new TemanModel();
        
        // Decode keyword jika mengandung spasi/karakter khusus (URL encoded)
        $keyword = urldecode($keyword);

        $kontak = $temanModel->select('friends.*, users.name, users.profile_pic, users.nim')
            ->groupStart()
                ->where('friends.user_id', $userId)
                ->orWhere('friends.friend_id', $userId)
            ->groupEnd()
            ->where('friends.status', 'accepted')
            // Join ke tabel users untuk mendapatkan detail lawan teman
            ->join('users', 'users.id = IF(friends.user_id = '.$userId.', friends.friend_id, friends.user_id)', 'left')
            ->groupStart()
                ->like('users.name', $keyword)
                ->orLike('users.nim', $keyword)
            ->groupEnd()
            ->findAll();

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $kontak
        ]);
    }

    public function deleteFriend(int $myId, int $friendId)
    {
        $this->setCorsHeaders();
        
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(ResponseInterface::HTTP_OK);
        }

        $db = \Config\Database::connect();
        
        $sql = "DELETE FROM friends 
                WHERE (user_id = ? AND friend_id = ?) 
                   OR (user_id = ? AND friend_id = ?)";
                   
        try {
            $db->query($sql, [$myId, $friendId, $friendId, $myId]);
            
            if ($db->affectedRows() > 0) {
                return $this->response->setJSON([
                    'status' => 'success',
                    'message' => 'Pertemanan berhasil dihapus'
                ]);
            } else {
                return $this->response->setStatusCode(404)->setJSON([
                    'status' => 'error',
                    'message' => 'Data pertemanan tidak ditemukan'
                ]);
            }
        } catch (\Exception $e) {
            return $this->response->setStatusCode(500)->setJSON([
                'status' => 'error',
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ]);
        }
    }

    public function blacklistFriend()
    {
        $this->setCorsHeaders();
        
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(ResponseInterface::HTTP_OK);
        }

        $json = $this->request->getJSON();

        if (!$json || !isset($json->user_id) || !isset($json->friend_id)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status' => 'error',
                'message' => 'Data tidak lengkap (user_id dan friend_id diperlukan)'
            ]);
        }

        $myId = $json->user_id;
        $friendId = $json->friend_id;

        $db = \Config\Database::connect();

        // Otomatis membuat kolom blocked_by jika belum ada di tabel friends
        if (!$db->fieldExists('blocked_by', 'friends')) {
            $forge = \Config\Database::forge();
            $forge->addColumn('friends', [
                'blocked_by' => [
                    'type' => 'INT',
                    'null' => true
                ]
            ]);
        }

        $sql = "UPDATE friends 
                SET status = 'blocked', blocked_by = ? 
                WHERE (user_id = ? AND friend_id = ?) 
                   OR (user_id = ? AND friend_id = ?)";

        try {
            $db->query($sql, [$myId, $myId, $friendId, $friendId, $myId]);

            // Jika belum ada record pertemanan sama sekali, kita buat baris baru khusus block
            if ($db->affectedRows() == 0) {
                $insertSql = "INSERT INTO friends (user_id, friend_id, status, created_at, blocked_by) VALUES (?, ?, 'blocked', NOW(), ?)";
                $db->query($insertSql, [$myId, $friendId, $myId]);
            }
            
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Pengguna berhasil diblokir'
            ]);
        } catch (\Exception $e) {
            return $this->response->setStatusCode(500)->setJSON([
                'status' => 'error',
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ]);
        }
    }
}
