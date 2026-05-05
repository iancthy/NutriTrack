<?php
require_once 'config.php';

$conn = getDB();

// GET: Fetch suggestions
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    requireLogin();

    $submissionId = $_GET['submission_id'] ?? null;
    $status       = $_GET['status']        ?? null;

    if ($submissionId) {
        $stmt = $conn->prepare("
            SELECT bs.*, u.name AS bhw_name, b.assigned_purok AS bhw_purok
            FROM bhw_suggestions bs
            JOIN users u ON bs.bhw_id = u.id
            JOIN bhws  b ON bs.bhw_id = b.user_id
            WHERE bs.submission_id = ?
            ORDER BY bs.created_at DESC
        ");
        $stmt->bind_param("i", $submissionId);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));

    } elseif ($_SESSION['user_role'] === 'admin') {
        $sql = "
            SELECT bs.*, c.name AS child_name, u.name AS bhw_name,
                   sub.height, sub.weight, sub.bmi
            FROM bhw_suggestions bs
            JOIN submissions sub ON bs.submission_id = sub.id
            JOIN children c     ON sub.child_id = c.id
            JOIN users u        ON bs.bhw_id = u.id
        ";
        if ($status) {
            $sql .= " WHERE bs.status = '" . $conn->real_escape_string($status) . "'";
        }
        $sql .= " ORDER BY bs.created_at DESC";
        sendJSON($conn->query($sql)->fetch_all(MYSQLI_ASSOC));

    } elseif ($_SESSION['user_role'] === 'bhw') {
        $sql = "
            SELECT bs.*, c.name AS child_name, sub.height, sub.weight, sub.bmi
            FROM bhw_suggestions bs
            JOIN submissions sub ON bs.submission_id = sub.id
            JOIN children c     ON sub.child_id = c.id
            WHERE bs.bhw_id = '" . $conn->real_escape_string($_SESSION['user_id']) . "'
        ";
        if ($status) {
            $sql .= " AND bs.status = '" . $conn->real_escape_string($status) . "'";
        }
        $sql .= " ORDER BY bs.created_at DESC";
        sendJSON($conn->query($sql)->fetch_all(MYSQLI_ASSOC));

    } else {
        // Parent — approved suggestions for their children only
        $stmt = $conn->prepare("
            SELECT bs.*, u.name AS bhw_name, c.name AS child_name,
                   sub.height, sub.weight, sub.bmi
            FROM bhw_suggestions bs
            JOIN submissions sub ON bs.submission_id = sub.id
            JOIN children c     ON sub.child_id = c.id
            JOIN users u        ON bs.bhw_id = u.id
            WHERE c.parent_id = ? AND bs.status = 'approved'
            ORDER BY bs.created_at DESC
        ");
        $stmt->bind_param("s", $_SESSION['user_id']);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));
    }
}

// POST: Create suggestion (BHW only)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireRole('bhw');

    $input = json_decode(file_get_contents('php://input'), true);

    $submissionId      = $input['submission_id']      ?? '';
    $dietarySuggestion = $input['dietary_suggestion']  ?? '';
    $interventionPlan  = $input['intervention_plan']   ?? '';
    $followupDate      = $input['followup_date']        ?? null;

    if (empty($submissionId) || empty($dietarySuggestion)) {
        sendJSON(['error' => 'Submission ID and dietary suggestion are required'], 400);
    }

    // Check for duplicate
    $checkStmt = $conn->prepare("SELECT id FROM bhw_suggestions WHERE submission_id = ? AND bhw_id = ?");
    $checkStmt->bind_param("is", $submissionId, $_SESSION['user_id']);
    $checkStmt->execute();
    if ($checkStmt->get_result()->num_rows > 0) {
        sendJSON(['error' => 'You have already submitted a suggestion for this submission'], 400);
    }

    $stmt = $conn->prepare("
        INSERT INTO bhw_suggestions (submission_id, bhw_id, dietary_suggestion, intervention_plan, followup_date, status)
        VALUES (?, ?, ?, ?, ?, 'pending')
    ");
    $stmt->bind_param("issss", $submissionId, $_SESSION['user_id'], $dietarySuggestion, $interventionPlan, $followupDate);

    if ($stmt->execute()) {
        sendJSON(['success' => true, 'message' => 'Suggestion submitted for admin approval']);
    } else {
        sendJSON(['error' => 'Failed to submit suggestion: ' . $conn->error], 500);
    }
}
?>
