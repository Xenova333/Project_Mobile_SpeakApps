<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BlockedUser extends Model
{
    use HasFactory;

    /**
     * Nama tabel di database.
     */
    protected $table = 'blocked_users';

    /**
     * Kolom yang dapat diisi secara massal.
     */
    protected $fillable = [
        'user_id',
        'blocked_id',
    ];

    /**
     * Nonaktifkan updated_at karena hanya ada created_at.
     */
    const UPDATED_AT = null;

    // --- RELASI ---

    /**
     * User yang melakukan pemblokiran.
     */
    public function blocker()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * User yang diblokir.
     */
    public function blocked()
    {
        return $this->belongsTo(User::class, 'blocked_id');
    }
}