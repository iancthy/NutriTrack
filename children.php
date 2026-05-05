<?php
require_once 'config.php';

$conn = getDB();

// GET: Fetch children
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    requireLogin();

    $childId  = $_GET['child_id']  ?? null;
    $parentId = $_GET['parent_id'] ?? null;

    if ($childId) {
        // Single child with submissions
        $stmt = $conn->prepare("
            SELECT c.*, u.name AS parent_name, p.contact AS parent_contact, p.region AS parent_region, c.purok, c.bhw_id, bu.name AS bhw_name
            FROM children c
            JOIN users u   ON c.parent_id = u.id
            JOIN parents p ON c.parent_id = p.user_id
            LEFT JOIN users bu ON c.bhw_id = bu.id
            WHERE c.id = ?
        ");
        $stmt->bind_param("s", $childId);
        $stmt->execute();
        $child = $stmt->get_result()->fetch_assoc();

        if (!$child) {
            sendJSON(['error' => 'Child not found'], 404);
        }

        // Submissions for this child
        $subStmt = $conn->prepare("
            SELECT s.*,
                   (SELECT status FROM bhw_suggestions WHERE submission_id = s.id ORDER BY created_at DESC LIMIT 1) AS suggestion_status
            FROM submissions s
            WHERE s.child_id = ?
            ORDER BY s.date_submitted DESC
        ");
        $subStmt->bind_param("s", $childId);
        $subStmt->execute();
        $child['submissions'] = $subStmt->get_result()->fetch_all(MYSQLI_ASSOC);

        sendJSON($child);

    } elseif ($_SESSION['user_role'] === 'parent') {
        // Parent fetching their own children
        $stmt = $conn->prepare("SELECT * FROM children WHERE parent_id = ?");
        $stmt->bind_param("s", $_SESSION['user_id']);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));

    } elseif ($parentId) {
        // Allow BHW/Admin to filter children by parent_id when requested
        $stmt = $conn->prepare("SELECT * FROM children WHERE parent_id = ?");
        $stmt->bind_param("s", $parentId);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));

    } else {
        // BHW or Admin — all children with parent info
        requireRole('bhw');
        $result = $conn->query("
            SELECT c.*, u.name AS parent_name, p.contact AS parent_contact, p.region AS parent_region, c.purok, c.bhw_id, bu.name AS bhw_name
            FROM children c
            JOIN users u   ON c.parent_id = u.id
            JOIN parents p ON c.parent_id = p.user_id
            LEFT JOIN users bu ON c.bhw_id = bu.id
            ORDER BY c.created_at DESC
        ");
        sendJSON($result->fetch_all(MYSQLI_ASSOC));
    }
}

// POST: Add new child (BHW only)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireRole('bhw');

    $input = json_decode(file_get_contents('php://input'), true);

    $name     = $input['name']      ?? '';
    $age      = $input['age']       ?? '';
    $sex      = $input['sex']       ?? 'Male';
    $parentId = $input['parent_id'] ?? '';
    $purok    = $input['purok']      ?? '';
    $bhwId    = $input['bhw_id']     ?? null;

    if (empty($name) || empty($age) || empty($parentId) || empty($purok)) {
        sendJSON(['error' => 'Name, age, parent_id, and purok are required'], 400);
    }

    if ($age < 5 || $age > 15) {
        sendJSON(['error' => 'Age must be between 5 and 15'], 400);
    }

    // Verify parent exists in users AND parents table
    $parentCheck = $conn->prepare("
        SELECT u.id FROM users u
        JOIN parents p ON u.id = p.user_id
        WHERE u.id = ? AND u.role = 'parent'
    ");
    $parentCheck->bind_param("s", $parentId);
    $parentCheck->execute();
    if ($parentCheck->get_result()->num_rows === 0) {
        sendJSON(['error' => 'Parent account not found'], 400);
    }

    // Generate child ID
    $result  = $conn->query("SELECT MAX(CAST(SUBSTRING(id, 2) AS UNSIGNED)) AS max_id FROM children WHERE id LIKE 'C%'");
    $row     = $result->fetch_assoc();
    $nextId  = ($row['max_id'] ?? 0) + 1;
    $childId = 'C' . str_pad($nextId, 3, '0', STR_PAD_LEFT);

    $stmt = $conn->prepare("INSERT INTO children (id, name, age, sex, parent_id, purok, bhw_id) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssissss", $childId, $name, $age, $sex, $parentId, $purok, $bhwId);

    if ($stmt->execute()) {
        sendJSON(['success' => true, 'message' => 'Child enrolled successfully', 'child_id' => $childId]);
    } else {
        sendJSON(['error' => 'Failed to enroll child: ' . $conn->error], 500);
    }
}
?>
