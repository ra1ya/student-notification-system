<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$code = post_string('code', 100);
$fullname = post_string('fullname', 255);
$department = post_string('dep', 100);
$level = post_string('level', 20);

if ($code === '' || $fullname === '' || $department === '' || !valid_level($level, false)) {
    json_response([
        'success' => false,
        'error' => 'Invalid student data',
    ], 422);
}

require_admin($department);
$connection = db_connection();

$check = prepared_statement($connection, 'SELECT id FROM student WHERE code = ? LIMIT 1');
$check->bind_param('s', $code);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    $check->close();
    json_response([
        'success' => false,
        'error' => 'Student code already exists',
    ], 409);
}

$check->close();

$statement = prepared_statement(
    $connection,
    'INSERT INTO student (fullname, dep, level, code) VALUES (?, ?, ?, ?)'
);
$statement->bind_param('ssss', $fullname, $department, $level, $code);

if (!$statement->execute()) {
    $statement->close();
    json_response([
        'success' => false,
        'error' => 'Unable to add student',
    ], 500);
}

$studentId = $statement->insert_id;
$statement->close();

json_response([
    'success' => true,
    'student' => [
        'id' => (int) $studentId,
        'code' => $code,
        'fullname' => $fullname,
        'dep' => $department,
        'level' => $level,
    ],
], 201);
