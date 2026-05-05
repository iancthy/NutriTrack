<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

requireRole('admin');

$input = json_decode(file_get_contents('php://input'), true);

$suggestionId  = $input['suggestion_id']  ?? '';
$action        = $input['action']          ?? '';
$adminFeedback = $input['admin_feedback']  ?? '';

if (empty($suggestionId) || empty($action)) {
    sendJSON(['error' => 'Suggestion ID and action are required'], 400);
}

if (!in_array($action, ['approve', 'disapprove'])) {
    sendJSON(['error' => 'Action must be "approve" or "disapprove"'], 400);
}

$conn = getDB();

// Verify suggestion exists
$suggestionStmt = $conn->prepare("SELECT id FROM bhw_suggestions WHERE id = ?");
$suggestionStmt->bind_param("i", $suggestionId);
$suggestionStmt->execute();
if ($suggestionStmt->get_result()->num_rows === 0) {
    sendJSON(['error' => 'Suggestion not found'], 404);
}

$status = ($action === 'approve') ? 'approved' : 'disapproved';

$stmt = $conn->prepare("
    UPDATE bhw_suggestions
    SET status = ?, admin_feedback = ?, admin_id = ?,
        approved_at = IF(? = 'approved', NOW(), NULL)
    WHERE id = ?
");
$stmt->bind_param("ssssi", $status, $adminFeedback, $_SESSION['user_id'], $status, $suggestionId);

if ($stmt->execute()) {
    sendJSON([
        'success' => true,
        'message' => 'Suggestion ' . $status . ' successfully',
        'status'  => $status
    ]);
} else {
    sendJSON(['error' => 'Failed to update suggestion: ' . $conn->error], 500);
}
?>
