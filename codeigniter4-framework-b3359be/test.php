<?php
$pdo = new PDO('mysql:host=localhost;dbname=speakapp_db;charset=utf8', 'root', '');
$stmt = $pdo->query('SELECT * FROM users WHERE id=5');
print_r($stmt->fetch(PDO::FETCH_ASSOC));
