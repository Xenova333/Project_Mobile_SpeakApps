<?php

namespace App\Models;

use CodeIgniter\Model;

class ChatModel extends Model
{
    protected $table            = 'chats';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'sender_id',
        'receiver_id',
        'message',
        'reply_to_id',
        'is_read',
        'created_at'
    ];

    // Dates
    protected $useTimestamps = false; // Karena di Laravel model-nya tidak punya updated_at, kita tangani manual
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // Validation
    protected $validationRules      = [];
    protected $validationMessages   = [];
    protected $skipValidation       = false;
    protected $cleanValidationRules = true;

    /**
     * Mengambil riwayat chat antara dua user (User A dan User B)
     *
     * @param int $user1 ID user pertama
     * @param int $user2 ID user kedua
     * @return array
     */
    public function getChatHistory($user1, $user2)
    {
        return $this->groupStart()
                        ->where('sender_id', $user1)
                        ->where('receiver_id', $user2)
                    ->groupEnd()
                    ->orGroupStart()
                        ->where('sender_id', $user2)
                        ->where('receiver_id', $user1)
                    ->groupEnd()
                    ->orderBy('created_at', 'ASC')
                    ->findAll();
    }
}