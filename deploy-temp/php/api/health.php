<?php
header('Content-Type: application/json');

$response = [
    'status' => 'ok',
    'timestamp' => time(),
    'version' => '1.0.0',
    'environment' => 'local'
];

echo json_encode($response);
exit;
?>


