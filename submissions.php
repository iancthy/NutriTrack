<?php
require_once 'config.php';

$conn = getDB();

// GET: Fetch submissions
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    requireLogin();

    $childId = $_GET['child_id'] ?? null;

    if ($childId) {
        $stmt = $conn->prepare("
            SELECT s.*, c.name AS child_name
            FROM submissions s
            JOIN children c ON s.child_id = c.id
            WHERE s.child_id = ?
            ORDER BY s.date_submitted DESC
        ");
        $stmt->bind_param("s", $childId);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));

    } elseif ($_SESSION['user_role'] === 'bhw' || $_SESSION['user_role'] === 'admin') {
        $result = $conn->query("
            SELECT s.*, c.name AS child_name, c.purok AS child_purok, c.age AS child_age, c.parent_id,
                   (SELECT status FROM bhw_suggestions WHERE submission_id = s.id ORDER BY created_at DESC LIMIT 1) AS suggestion_status
            FROM submissions s
            JOIN children c ON s.child_id = c.id
            ORDER BY s.date_submitted DESC
        ");
        sendJSON($result->fetch_all(MYSQLI_ASSOC));

    } else {
        // Parent — only their children's submissions
        $stmt = $conn->prepare("
            SELECT s.*, c.name AS child_name
            FROM submissions s
            JOIN children c ON s.child_id = c.id
            WHERE c.parent_id = ?
            ORDER BY s.date_submitted DESC
        ");
        $stmt->bind_param("s", $_SESSION['user_id']);
        $stmt->execute();
        sendJSON($stmt->get_result()->fetch_all(MYSQLI_ASSOC));
    }
}

// POST: Create submission (Parent only)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireRole('parent');

    $input = json_decode(file_get_contents('php://input'), true);

    $childId         = $input['child_id']          ?? '';
    $height          = $input['height']             ?? null;
    $weight          = $input['weight']             ?? null;
    $medicalCondition= $input['medical_condition']  ?? '';
    $medication      = $input['medication']         ?? '';
    $dietaryIntake   = $input['dietary_intake']     ?? '';
    $dateSubmitted   = $input['date_submitted']     ?? date('Y-m-d');

    if (empty($childId) || !$height || !$weight) {
        sendJSON(['error' => 'Child ID, height, and weight are required'], 400);
    }

    if ($height < 50 || $height > 250) {
        sendJSON(['error' => 'Height must be between 50 and 250 cm'], 400);
    }

    if ($weight < 5 || $weight > 200) {
        sendJSON(['error' => 'Weight must be between 5 and 200 kg'], 400);
    }

    // Verify child belongs to this parent
    $verifyStmt = $conn->prepare("SELECT id FROM children WHERE id = ? AND parent_id = ?");
    $verifyStmt->bind_param("ss", $childId, $_SESSION['user_id']);
    $verifyStmt->execute();
    if ($verifyStmt->get_result()->num_rows === 0) {
        sendJSON(['error' => 'You do not have permission to submit for this child'], 403);
    }

    // Check for pending submission
    $checkStmt = $conn->prepare("SELECT s.id FROM submissions s LEFT JOIN bhw_suggestions bs ON s.id = bs.submission_id WHERE s.child_id = ? AND (bs.id IS NULL OR bs.status IN ('pending', 'disapproved')) LIMIT 1");
    $checkStmt->bind_param("s", $childId);
    $checkStmt->execute();
    if ($checkStmt->get_result()->num_rows > 0) {
        sendJSON(['error' => 'You have a pending submission for this child that has not been approved yet. Please wait for approval before submitting a new report.'], 400);
    }

    // Calculate BMI
    $bmi = round($weight / pow($height / 100, 2), 2);

    $stmt = $conn->prepare("
        INSERT INTO submissions (child_id, height, weight, medical_condition, medication, dietary_intake, bmi, date_submitted)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->bind_param("sddsssds", $childId, $height, $weight, $medicalCondition, $medication, $dietaryIntake, $bmi, $dateSubmitted);

    if ($stmt->execute()) {
        sendJSON([
            'success'       => true,
            'message'       => 'Health data submitted successfully',
            'submission_id' => $stmt->insert_id,
            'bmi'           => $bmi
        ]);
    } else {
        sendJSON(['error' => 'Failed to submit: ' . $conn->error], 500);
    }
}
?>
