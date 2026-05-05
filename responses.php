<?php
require_once 'config.php';

$conn = getDB();

// GET: Fetch improvements
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    requireLogin();

    $childId = $_GET['child_id'] ?? null;

    if ($_SESSION['user_role'] === 'bhw') {
        $sql = "
            SELECT i.*, c.name AS child_name, u.name AS bhw_name
            FROM improvements i
            JOIN children c ON i.child_id = c.id
            JOIN users u    ON i.bhw_id   = u.id
            WHERE i.bhw_id = '" . $conn->real_escape_string($_SESSION['user_id']) . "'
        ";
        if ($childId) {
            $sql .= " AND i.child_id = '" . $conn->real_escape_string($childId) . "'";
        }
        $sql .= " ORDER BY i.recorded_date DESC";
        sendJSON($conn->query($sql)->fetch_all(MYSQLI_ASSOC));

    } elseif ($_SESSION['user_role'] === 'parent') {
        $sql = "
            SELECT i.*, c.name AS child_name, u.name AS bhw_name, b.assigned_purok AS bhw_purok
            FROM improvements i
            JOIN children c ON i.child_id = c.id
            LEFT JOIN users u    ON i.bhw_id   = u.id
            LEFT JOIN bhws b     ON i.bhw_id   = b.user_id
            WHERE i.bhw_id IS NULL AND i.child_id IN (SELECT id FROM children WHERE parent_id = '" . $conn->real_escape_string($_SESSION['user_id']) . "')
        ";
        if ($childId) {
            $sql .= " AND i.child_id = '" . $conn->real_escape_string($childId) . "'";
        }
        $sql .= " ORDER BY i.recorded_date DESC";
        sendJSON($conn->query($sql)->fetch_all(MYSQLI_ASSOC));

    } else {
        // Admin — all improvements
        $result = $conn->query("
            SELECT i.*, c.name AS child_name, u.name AS bhw_name, b.assigned_purok AS bhw_purok
            FROM improvements i
            JOIN children c ON i.child_id = c.id
            JOIN users u    ON i.bhw_id   = u.id
            JOIN bhws b     ON i.bhw_id   = b.user_id
            ORDER BY i.recorded_date DESC
        ");
        sendJSON($result->fetch_all(MYSQLI_ASSOC));
    }
}

// POST: Record improvement (Parent only)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireRole('parent');

    $input = json_decode(file_get_contents('php://input'), true);

    $childId         = $input['child_id']         ?? '';
    $improvementNotes= $input['improvement_notes'] ?? '';
    $weightChange    = $input['weight_change']     ?? null;
    $bmiChange       = $input['bmi_change']        ?? null;
    $recordedDate    = $input['recorded_date']     ?? date('Y-m-d');

    if (empty($childId)) {
        sendJSON(['error' => 'Child ID is required'], 400);
    }

    // Verify child belongs to this parent
    $verifyStmt = $conn->prepare("SELECT id FROM children WHERE id = ? AND parent_id = ?");
    $verifyStmt->bind_param("ss", $childId, $_SESSION['user_id']);
    $verifyStmt->execute();
    if ($verifyStmt->get_result()->num_rows === 0) {
        sendJSON(['error' => 'You do not have permission to record improvement for this child'], 403);
    }

    $stmt = $conn->prepare("
        INSERT INTO improvements (child_id, bhw_id, improvement_notes, weight_change, bmi_change, recorded_date)
        VALUES (?, NULL, ?, ?, ?, ?)
    ");
    $stmt->bind_param("ssdds", $childId, $improvementNotes, $weightChange, $bmiChange, $recordedDate);

    if ($stmt->execute()) {
        sendJSON(['success' => true, 'message' => 'Improvement recorded successfully']);
    } else {
        sendJSON(['error' => 'Failed to record improvement: ' . $conn->error], 500);
    }
}
?>
