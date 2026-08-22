<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$student = require_student();
$department = (string) ($student['dep'] ?? '');
$level = (string) ($student['level'] ?? '');

if ($department === '' || !valid_level($level, false)) {
    json_response([
        'success' => false,
        'error' => 'Invalid student token',
    ], 401);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    "SELECT id, mess, dep, level, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS times
     FROM messages
     WHERE dep = ? AND (level = ? OR level = 'all')
     ORDER BY id DESC"
);
$statement->bind_param('ss', $department, $level);
$statement->execute();
$statement->bind_result($id, $message, $dep, $messageLevel, $times);

$messages = [];
while ($statement->fetch()) {
    $messages[] = [
        'id' => (int) $id,
        'mess' => (string) $message,
        'dep' => (string) $dep,
        'level' => (string) $messageLevel,
        'times' => (string) $times,
    ];
}

$statement->close();
json_response([
    'success' => true,
    'messages' => $messages,
]);
