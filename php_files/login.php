<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$username = post_string('username');
$password = post_string('password');

if ($username === '' || $password === '') {
    json_response(['result' => 'not here']);
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
    json_response(['result' => 'not here']);
}

$statement->bind_result($id, $dbUsername, $storedPassword, $department);
$statement->fetch();
$statement->close();

if (!password_matches($password, (string) $storedPassword)) {
    json_response(['result' => 'not here']);
}

json_response([
    'id' => (int) $id,
    'username' => $dbUsername,
    'dep' => $department,
]);
