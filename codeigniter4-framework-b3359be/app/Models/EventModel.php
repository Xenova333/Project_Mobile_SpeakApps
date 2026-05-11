<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    /**
     * Nama tabel di database.
     */
    protected $table = 'events';

    /**
     * Kolom yang dapat diisi secara massal.
     */
    protected $fillable = [
        'title',
        'description',
        'image',
        'event_date',
        'event_link',
    ];

    /**
     * Casting tipe data.
     * Memastikan 'event_date' diperlakukan sebagai objek Carbon/Tanggal.
     */
    protected $casts = [
        'event_date' => 'date',
    ];

    /**
     * Karena di tabel Anda hanya ada 'created_at' dan bukan 'updated_at',
     * kita perlu mematikan fitur updated_at otomatis dari Laravel.
     */
    const UPDATED_AT = null;
}