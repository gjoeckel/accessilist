<?php
header('Content-Type: application/json');

function send_json($arr) {
  echo json_encode($arr);
  exit;
}

function send_error($message, $code = 400) {
  http_response_code($code);
  send_json([
    'success' => false,
    'message' => $message,
    'timestamp' => time()
  ]);
}

function send_success($payload = []) {
  $base = [
    'success' => true,
    'timestamp' => time()
  ];
  
  // If payload is provided, wrap it in 'data' property per SRD API contract
  if (!empty($payload)) {
    $base['data'] = $payload;
  }
  
  send_json($base);
}

function validate_session_key($sessionKey) {
  if (!preg_match('/^[a-zA-Z0-9]{3}$/', $sessionKey)) {
    send_error('Invalid session key', 400);
  }
}

function saves_path_for($sessionKey) {
  return __DIR__ . '/../../saves/' . $sessionKey . '.json';
}


