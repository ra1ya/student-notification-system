<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$department = post_string('dep');
$level = post_string('level');

if ($department === '' || !valid_level($level, true)) {
    json_response([]);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'SELECT id, mess, dep, level, times FROM messages WHERE dep = ? AND level = ?'
);
$statement->bind_param('ss', $department, $level);
$statement->execute();
$statement->bind_result($id, $message, $dep, $messageLevel, $times);

$messages = [];
while ($statement->fetch()) {
    $messages[] = [
        'id' => (int) $id,
        'mess' => $message,
        'dep' => $dep,
        'level' => $messageLevel,
        'times' => $times,
    ];
}

$statement->close();
json_response($messages);
