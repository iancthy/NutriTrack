<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// =============================================
// DATABASE CONFIGURATION
// Change these values to match your setup
// =============================================
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');       // <- XAMPP default is empty password. If using Laragon, try 'root'. MAMP try 'root'.
define('DB_NAME', 'nutritrack_db');

// Start session for user state
session_start();

function getDB() {
    // Suppress default warnings so we can handle them ourselves
    $conn = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

    if ($conn->connect_errno) {
        $errno  = $conn->connect_errno;
        $errstr = $conn->connect_error;

        // Give a helpful message depending on the error
        if ($errno === 1045) {
            $msg = "Access denied: wrong DB_USER or DB_PASS in config.php (errno $errno).";
        } elseif ($errno === 1049) {
            $msg = "Database 'nutritrack_db' does not exist. Please import nutritrack_db.sql first (errno $errno).";
        } elseif ($errno === 2002 || $errno === 2003) {
            $msg = "Cannot reach MySQL server on '" . DB_HOST . "'. Make sure MySQL/MariaDB is running (errno $errno).";
        } else {
            $msg = "Connection failed (errno $errno): $errstr";
        }

        http_response_code(500);
        echo json_encode(['error' => $msg]);
        exit();
    }

    $conn->set_charset("utf8mb4");
    return $conn;
}

function isLoggedIn() {
    return isset($_SESSION['user_id']) && isset($_SESSION['user_role']);
}

function requireLogin() {
    if (!isLoggedIn()) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized. Please login.']);
        exit();
    }
}

function requireRole($role) {
    requireLogin();
    if ($_SESSION['user_role'] !== $role && $_SESSION['user_role'] !== 'admin') {
        http_response_code(403);
        echo json_encode(['error' => 'Forbidden. Insufficient permissions.']);
        exit();
    }
}

function sendJSON($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}
?>
