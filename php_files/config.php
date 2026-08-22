<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

function json_response($payload, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function post_string(string $key, string $default = ''): string
{
    $value = $_POST[$key] ?? $default;

    if (!is_string($value)) {
        return $default;
    }

    return trim($value);
}

function env_or_default(string $key, string $default): string
{
    $value = getenv($key);
    return ($value === false || $value === '') ? $default : $value;
}

function db_connection(): mysqli
{
    static $connection = null;

    if ($connection instanceof mysqli) {
        return $connection;
    }

    $host = env_or_default('DB_HOST', 'localhost');
    $user = env_or_default('DB_USER', 'root');
    $pass = env_or_default('DB_PASS', '');
    $name = env_or_default('DB_NAME', 'chat');

    mysqli_report(MYSQLI_REPORT_OFF);
    $connection = new mysqli($host, $user, $pass, $name);

    if ($connection->connect_errno) {
        json_response([
            'success' => false,
            'error' => 'Database connection failed',
        ], 500);
    }

    if (!$connection->set_charset('utf8mb4')) {
        json_response([
            'success' => false,
            'error' => 'Unable to configure database character set',
        ], 500);
    }

    return $connection;
}

function prepared_statement(mysqli $connection, string $sql): mysqli_stmt
{
    $statement = $connection->prepare($sql);

    if (!$statement) {
        json_response([
            'success' => false,
            'error' => 'Unable to prepare database query',
        ], 500);
    }

    return $statement;
}

function valid_level(string $level, bool $allowAll = true): bool
{
    $levels = ['L1', 'L2', 'L3', 'L4'];

    if ($allowAll) {
        $levels[] = 'all';
    }

    return in_array($level, $levels, true);
}

function password_matches(string $plainPassword, string $storedPassword): bool
{
    $isHash = preg_match('/^\$(2y|2a|2b|argon2i|argon2id)\$/', $storedPassword) === 1;

    if ($isHash) {
        return password_verify($plainPassword, $storedPassword);
    }

    // Backward compatibility for older local demo databases that stored
    // plaintext passwords. New deployments should store password hashes only.
    return hash_equals($storedPassword, $plainPassword);
}
