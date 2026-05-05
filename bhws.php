<?php
require_once 'config.php';

session_start();

// GET: Fetch BHWs by purok (for enrollment)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $purok = $_GET['purok'] ?? '';
    if (empty($purok)) {
        sendJSON(['error' => 'Purok parameter required'], 400);
    }

    $stmt = $conn->prepare("SELECT u.id AS user_id, u.name, b.employee_id FROM users u JOIN bhws b ON u.id = b.user_id WHERE b.assigned_purok = ?");
    $stmt->bind_param("s", $purok);
    $stmt->execute();
    $result = $stmt->get_result();
    sendJSON($result->fetch_all(MYSQLI_ASSOC));
}

// POST: Create new BHW (Admin only)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireRole('admin');

    $input = json_decode(file_get_contents('php://input'), true);

    $name       = $input['name']        ?? '';
    $employeeId = $input['employee_id'] ?? '';
    $purok      = $input['purok']       ?? '';
    $username   = $input['username']    ?? '';
    $password   = $input['password']    ?? '';

    if (empty($name) || empty($employeeId) || empty($purok) || empty($username) || empty($password)) {
        sendJSON(['error' => 'All fields are required'], 400);
    }

    // Check if username exists
    $checkStmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $checkStmt->bind_param("s", $username);
    $checkStmt->execute();
    if ($checkStmt->get_result()->num_rows > 0) {
        sendJSON(['error' => 'Username already exists'], 400);
    }

    // Insert user
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $userStmt = $conn->prepare("INSERT INTO users (name, username, password, role) VALUES (?, ?, ?, 'bhw')");
    $userStmt->bind_param("sss", $name, $username, $hashedPassword);
    if (!$userStmt->execute()) {
        sendJSON(['error' => 'Failed to create user: ' . $conn->error], 500);
    }
    $userId = $conn->insert_id;

    // Insert BHW
    $bhwStmt = $conn->prepare("INSERT INTO bhws (user_id, employee_id, assigned_purok) VALUES (?, ?, ?)");
    $bhwStmt->bind_param("sss", $userId, $employeeId, $purok);
    if (!$bhwStmt->execute()) {
        sendJSON(['error' => 'Failed to create BHW: ' . $conn->error], 500);
    }

    sendJSON(['success' => true, 'message' => 'BHW created successfully']);
}
?>

        sendJSON(['success' => true, 'message' => 'BHW created successfully', 'user_id' => $employeeId]);
    } catch (Exception $e) {
        $conn->rollback();
        sendJSON(['error' => 'Failed to create BHW: ' . $e->getMessage()], 500);
    }
}
?>