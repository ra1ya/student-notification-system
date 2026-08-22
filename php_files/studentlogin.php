<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

$code = post_string('code');

if ($code === '') {
    json_response(['result' => 'not here']);
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
    json_response(['result' => 'not here']);
}

$statement->bind_result($id, $studentCode, $fullname, $department, $level);
$statement->fetch();
$statement->close();

json_response([
    'id' => (int) $id,
    'code' => $studentCode,
    'fullname' => $fullname,
    'dep' => $department,
    'level' => $level,
]);
