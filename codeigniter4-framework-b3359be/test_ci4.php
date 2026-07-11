<?php
require 'vendor/autoload.php';
$app = require_once 'system/bootstrap.php';
$model = new \App\Models\UserModel();
$user = $model->findByNim('240302024');
echo "FIND BY NIM RESULT:\n";
print_r($user);
