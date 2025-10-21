<?php
// Don't send headers at file load - send in response functions instead
// This allows session_start() to be called before any headers are sent

function send_json($arr) {
  // Send Content-Type header here (not at file load)
  if (!headers_sent()) {
    header('Content-Type: application/json');
  }
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
  // Support both 3-char production keys (ABC, 0EX) and longer test keys (TEST-PROGRESS-50)
  if (!preg_match('/^[a-zA-Z0-9\-]{3,20}$/', $sessionKey)) {
    send_error('Invalid session key', 400);
  }
}

function saves_path_for($sessionKey) {
  // Use environment-configured sessions path (defaults to etc/sessions in production)
  global $sessionsPath;
  return $sessionsPath . '/' . $sessionKey . '.json';
}
