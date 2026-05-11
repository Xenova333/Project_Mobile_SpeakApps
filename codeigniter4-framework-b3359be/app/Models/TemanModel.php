<?php

namespace App\Models;

use CodeIgniter\Model;

class TemanModel extends Model
{
    protected $table            = 'friends';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields    = [
        'user_id',
        'friend_id',
        'status',
        'created_at'
    ];

    // Dates
    protected $useTimestamps = false; 
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // Validation
    protected $validationRules      = [];
    protected $validationMessages   = [];
    protected $skipValidation       = false;
    protected $cleanValidationRules = true;
}