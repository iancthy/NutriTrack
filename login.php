<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

$id       = $input['id']       ?? '';
$password = $input['password'] ?? '';
$role     = $input['role']     ?? '';

if (empty($id) || empty($password) || empty($role)) {
    sendJSON(['error' => 'ID, password, and role are required'], 400);
}

$conn = getDB();

// Check base users table
$stmt = $conn->prepare("SELECT id, name, role, password FROM users WHERE id = ? AND role = ?");
$stmt->bind_param("ss", $id, $role);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    sendJSON(['error' => 'Invalid ID or role'], 401);
}

$user = $result->fetch_assoc();

if ($password !== $user['password']) {
    sendJSON(['error' => 'Invalid password'], 401);
}

// Set session
$_SESSION['user_id']   = $user['id'];
$_SESSION['user_name'] = $user['name'];
$_SESSION['user_role'] = $user['role'];

$response = [
    'success' => true,
    'user'    => [
        'id'   => $user['id'],
        'name' => $user['name'],
        'role' => $user['role'],
    ]
];

// Fetch role-specific profile and attach to response
if ($user['role'] === 'parent') {
    $profileStmt = $conn->prepare("SELECT birthday, region, contact FROM parents WHERE user_id = ?");
    $profileStmt->bind_param("s", $user['id']);
    $profileStmt->execute();
    $profile = $profileStmt->get_result()->fetch_assoc();
    $response['user']['profile'] = $profile;

    // Fetch children
    $childrenStmt = $conn->prepare("SELECT id, name, age, sex FROM children WHERE parent_id = ?");
    $childrenStmt->bind_param("s", $user['id']);
    $childrenStmt->execute();
    $response['children'] = $childrenStmt->get_result()->fetch_all(MYSQLI_ASSOC);

} elseif ($user['role'] === 'bhw') {
    $profileStmt = $conn->prepare("SELECT employee_id, assigned_purok, contact FROM bhws WHERE user_id = ?");
    $profileStmt->bind_param("s", $user['id']);
    $profileStmt->execute();
    $profile = $profileStmt->get_result()->fetch_assoc();
    $response['user']['profile'] = $profile;

} elseif ($user['role'] === 'admin') {
    $profileStmt = $conn->prepare("SELECT department, contact FROM admins WHERE user_id = ?");
    $profileStmt->bind_param("s", $user['id']);
    $profileStmt->execute();
    $profile = $profileStmt->get_result()->fetch_assoc();
    $response['user']['profile'] = $profile;
}

sendJSON($response);
?>
