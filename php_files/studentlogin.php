<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$code = post_string('code', 100);

if ($code === '') {
    json_response([
        'success' => false,
        'error' => 'Student code is required',
    ], 422);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'SELECT id, code, fullname, dep, level FROM student WHERE code = ? LIMIT 1'
);
$statement->bind_param('s', $code);
$statement->execute();
$statement->store_result();

if ($statement->num_rows !== 1) {
    $statement->close();
    json_response([
        'success' => false,
        'error' => 'Student not found',
    ], 404);
}

$statement->bind_result($id, $studentCode, $fullname, $department, $level);
$statement->fetch();
$statement->close();

json_response([
    'success' => true,
    'token' => create_access_token('student', (int) $id, [
        'dep' => (string) $department,
        'level' => (string) $level,
    ]),
    'student' => [
        'id' => (int) $id,
        'code' => (string) $studentCode,
        'fullname' => (string) $fullname,
        'dep' => (string) $department,
        'level' => (string) $level,
    ],
]);
