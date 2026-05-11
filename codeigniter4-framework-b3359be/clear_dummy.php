<?php
$mysqli = new mysqli("localhost", "root", "", "speakapp_db");

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

// NIM user dummy yang ingin dihapus
$dummyNims = ['10001', '10002', '10003'];
$nimList = "'" . implode("','", $dummyNims) . "'";

// 1. Dapatkan ID dari user dummy tersebut
$result = $mysqli->query("SELECT id FROM users WHERE nim IN ($nimList)");
$ids = [];
while ($row = $result->fetch_assoc()) {
    $ids[] = $row['id'];
}

if (empty($ids)) {
    echo "Tidak ada data dummy yang ditemukan untuk NIM tersebut.\n";
    exit;
}

$idList = implode(",", $ids);

// 2. Hapus data di tabel friends (yang melibatkan user dummy)
$mysqli->query("DELETE FROM friends WHERE user_id IN ($idList) OR friend_id IN ($idList)");
$deletedFriends = $mysqli->affected_rows;

// 3. Hapus data di tabel chats (yang melibatkan user dummy)
$mysqli->query("DELETE FROM chats WHERE sender_id IN ($idList) OR receiver_id IN ($idList)");
$deletedChats = $mysqli->affected_rows;

// 4. Hapus data di tabel users
$mysqli->query("DELETE FROM users WHERE id IN ($idList)");
$deletedUsers = $mysqli->affected_rows;

echo "--- PEMBERSIHAN DATA DUMMY BERHASIL ---\n";
echo "User dihapus: $deletedUsers\n";
echo "Relasi teman dihapus: $deletedFriends\n";
echo "Riwayat chat dihapus: $deletedChats\n";
?>
