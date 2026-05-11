<?php
$mysqli = new mysqli("localhost", "root", "", "speakapp_db");
$res = $mysqli->query("SELECT id, nim, name FROM users");
while($row = $res->fetch_assoc()) {
    echo "ID: " . $row['id'] . " | NIM: " . $row['nim'] . " | Name: " . $row['name'] . "\n";
}
?>
