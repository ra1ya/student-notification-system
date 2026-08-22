<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$department = post_string('dep', 100);
$level = post_string('level', 20);

if ($department === '' || !valid_level($level, true)) {
    json_response([
        'success' => false,
        'error' => 'Invalid filters',
    ], 422);
}

require_admin($department);
$connection = db_connection();
$statement = prepared_statement(
    $connection,
    "SELECT id, mess, dep, level, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS times FROM messages WHERE dep = ? AND level = ? ORDER BY id DESC"
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
