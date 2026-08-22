<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$level = post_string('level', 20);
$message = post_string('message', 4000);
$department = post_string('dep', 100);

if ($message === '' || $department === '' || !valid_level($level, true)) {
    json_response([
        'success' => false,
        'error' => 'Invalid message data',
    ], 422);
}

require_admin($department);
$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'INSERT INTO messages (mess, dep, level) VALUES (?, ?, ?)'
);
$statement->bind_param('sss', $message, $department, $level);

if (!$statement->execute()) {
    $statement->close();
    json_response([
        'success' => false,
        'error' => 'Unable to save message',
    ], 500);
}

$messageId = $statement->insert_id;
$statement->close();

json_response([
    'success' => true,
    'message' => [
        'id' => (int) $messageId,
        'mess' => $message,
        'dep' => $department,
        'level' => $level,
    ],
], 201);
