<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$level = post_string('level');
$message = post_string('message');
$department = post_string('dep');
$time = post_string('time');

if ($message === '' || $department === '' || !valid_level($level, true)) {
    json_response([
        'success' => false,
        'error' => 'Invalid message data',
    ], 422);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'INSERT INTO messages (mess, dep, level, times) VALUES (?, ?, ?, ?)'
);
$statement->bind_param('ssss', $message, $department, $level, $time);

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
    'id' => (int) $messageId,
    'message' => $message,
    'dep' => $department,
    'level' => $level,
    'times' => $time,
]);
