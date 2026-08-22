<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$username = post_string('username', 100);
$password = post_string('password', 255);

if ($username === '' || $password === '') {
    json_response([
        'success' => false,
        'error' => 'Invalid credentials',
    ], 401);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'SELECT id, username, password, dep FROM admin WHERE username = ? LIMIT 1'
);
$statement->bind_param('s', $username);
$statement->execute();
$statement->store_result();

if ($statement->num_rows !== 1) {
    $statement->close();
    json_response([
        'success' => false,
        'error' => 'Invalid credentials',
    ], 401);
}

$statement->bind_result($id, $dbUsername, $storedPassword, $department);
$statement->fetch();
$statement->close();

if (!password_verify($password, (string) $storedPassword)) {
    json_response([
        'success' => false,
        'error' => 'Invalid credentials',
    ], 401);
}

json_response([
    'success' => true,
    'token' => create_access_token('admin', (int) $id, ['dep' => (string) $department]),
    'user' => [
        'id' => (int) $id,
        'username' => (string) $dbUsername,
        'dep' => (string) $department,
    ],
]);
