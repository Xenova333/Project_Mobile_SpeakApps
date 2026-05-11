<?php
$mysqli = new mysqli("localhost", "root", "", "speakapp_db");

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

// Tambah 3 user dummy pengirim request
$dummyUsers = [
    ['nim' => '10001', 'name' => 'Budi Santoso', 'password' => password_hash('123', PASSWORD_DEFAULT), 'semester' => '3', 'gender' => 'Laki-Laki'],
    ['nim' => '10002', 'name' => 'Siti Aminah', 'password' => password_hash('123', PASSWORD_DEFAULT), 'semester' => '5', 'gender' => 'Perempuan'],
    ['nim' => '10003', 'name' => 'Joko Widodo', 'password' => password_hash('123', PASSWORD_DEFAULT), 'semester' => '7', 'gender' => 'Laki-Laki']
];

$insertedUserIds = [];

foreach ($dummyUsers as $u) {
    // Check if exists
    $result = $mysqli->query("SELECT id FROM users WHERE nim = '{$u['nim']}'");
    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $insertedUserIds[] = $row['id'];
    } else {
        $stmt = $mysqli->prepare("INSERT INTO users (nim, name, password, semester, gender) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $u['nim'], $u['name'], $u['password'], $u['semester'], $u['gender']);
        $stmt->execute();
        $insertedUserIds[] = $mysqli->insert_id;
    }
}

// Ambil semua ID user untuk disuntikkan friend request dari ketiga dummy tersebut
$allUsers = [];
$res = $mysqli->query("SELECT id FROM users");
while($row = $res->fetch_assoc()) {
    $allUsers[] = $row['id'];
}

$count = 0;
foreach ($allUsers as $targetId) {
    // Jangan kirim request ke diri sendiri jika targetId adalah salah satu dari dummy
    foreach ($insertedUserIds as $senderId) {
        if ($senderId != $targetId) {
            // Check if already exist
            $chk = $mysqli->query("SELECT id FROM friends WHERE user_id = $senderId AND friend_id = $targetId");
            if ($chk->num_rows == 0) {
                // Insert request
                $date = date('Y-m-d H:i:s');
                $mysqli->query("INSERT INTO friends (user_id, friend_id, status, created_at) VALUES ($senderId, $targetId, 'pending', '$date')");
                $count++;
            }
        }
    }
}

echo "Berhasil membuat 3 user dummy dan mengirim $count permintaan pertemanan 'pending' ke seluruh pengguna.";
?>
