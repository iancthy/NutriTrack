<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

$name     = $input['name']     ?? '';
$birthday = $input['birthday'] ?? '';
$region   = $input['region']   ?? '';
$contact  = $input['contact']  ?? '';
$password = $input['password'] ?? '';

if (empty($name) || empty($birthday) || empty($region) || empty($password)) {
    sendJSON(['error' => 'Name, birthday, region, and password are required'], 400);
}

$conn = getDB();

// Generate Parent ID (PAR-XXX format)
$result = $conn->query("SELECT MAX(CAST(SUBSTRING(id, 5) AS UNSIGNED)) as max_id FROM users WHERE id LIKE 'PAR-%'");
$row    = $result->fetch_assoc();
$nextId = ($row['max_id'] ?? 0) + 1;
$parentId = 'PAR-' . str_pad($nextId, 3, '0', STR_PAD_LEFT);

// Begin transaction so both inserts succeed or both fail
$conn->begin_transaction();

try {
    // Insert into base users table
    $stmt = $conn->prepare("INSERT INTO users (id, name, role, password) VALUES (?, ?, 'parent', ?)");
    $stmt->bind_param("sss", $parentId, $name, $password);
    $stmt->execute();

    // Insert into parents profile table
    $profileStmt = $conn->prepare("INSERT INTO parents (user_id, birthday, region, contact) VALUES (?, ?, ?, ?)");
    $profileStmt->bind_param("ssss", $parentId, $birthday, $region, $contact);
    $profileStmt->execute();

    $conn->commit();

    sendJSON([
        'success' => true,
        'message' => 'Registration successful!',
        'user_id' => $parentId
    ]);
} catch (Exception $e) {
    $conn->rollback();
    sendJSON(['error' => 'Registration failed: ' . $e->getMessage()], 500);
}
?>
