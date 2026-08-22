<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

function json_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function post_string(string $key, int $maxLength = 255): string
{
    $value = $_POST[$key] ?? '';

    if (!is_string($value)) {
        return '';
    }

    $value = trim($value);

    if (mb_strlen($value) > $maxLength) {
        json_response([
            'success' => false,
            'error' => sprintf('%s is too long', $key),
        ], 422);
    }

    return $value;
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

    mysqli_report(MYSQLI_REPORT_OFF);

    $connection = new mysqli(
        env_or_default('DB_HOST', 'localhost'),
        env_or_default('DB_USER', 'root'),
        env_or_default('DB_PASS', ''),
        env_or_default('DB_NAME', 'chat')
    );

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

function base64url_encode(string $value): string
{
    return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
}

function base64url_decode(string $value): string|false
{
    $padding = strlen($value) % 4;
    if ($padding !== 0) {
        $value .= str_repeat('=', 4 - $padding);
    }

    return base64_decode(strtr($value, '-_', '+/'), true);
}

function app_key(): string
{
    return env_or_default('APP_KEY', 'local-demo-key-change-before-production');
}

function create_access_token(string $role, int $subjectId, array $claims = []): string
{
    $payload = array_merge([
        'role' => $role,
        'sub' => $subjectId,
        'iat' => time(),
        'exp' => time() + (8 * 60 * 60),
    ], $claims);

    $encodedPayload = base64url_encode(
        json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR)
    );
    $signature = hash_hmac('sha256', $encodedPayload, app_key(), true);

    return $encodedPayload . '.' . base64url_encode($signature);
}

function bearer_token(): string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';

    if ($header === '' && function_exists('getallheaders')) {
        $headers = getallheaders();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }

    if (!is_string($header) || !preg_match('/^Bearer\s+(.+)$/i', trim($header), $matches)) {
        return '';
    }

    return trim($matches[1]);
}

function require_access_token(string $requiredRole): array
{
    $token = bearer_token();

    if ($token === '') {
        json_response([
            'success' => false,
            'error' => 'Authentication required',
        ], 401);
    }

    $parts = explode('.', $token);
    if (count($parts) !== 2) {
        json_response([
            'success' => false,
            'error' => 'Invalid access token',
        ], 401);
    }

    [$encodedPayload, $encodedSignature] = $parts;
    $providedSignature = base64url_decode($encodedSignature);

    if ($providedSignature === false) {
        json_response([
            'success' => false,
            'error' => 'Invalid access token',
        ], 401);
    }

    $expectedSignature = hash_hmac('sha256', $encodedPayload, app_key(), true);
    if (!hash_equals($expectedSignature, $providedSignature)) {
        json_response([
            'success' => false,
            'error' => 'Invalid access token',
        ], 401);
    }

    $decodedPayload = base64url_decode($encodedPayload);
    if ($decodedPayload === false) {
        json_response([
            'success' => false,
            'error' => 'Invalid access token',
        ], 401);
    }

    try {
        $payload = json_decode($decodedPayload, true, 512, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        json_response([
            'success' => false,
            'error' => 'Invalid access token',
        ], 401);
    }

    if (!is_array($payload)
        || ($payload['role'] ?? '') !== $requiredRole
        || !isset($payload['sub'], $payload['exp'])
        || !is_numeric($payload['sub'])
        || !is_numeric($payload['exp'])
        || (int) $payload['exp'] < time()) {
        json_response([
            'success' => false,
            'error' => 'Expired or invalid access token',
        ], 401);
    }

    return $payload;
}

function require_admin(?string $expectedDepartment = null): array
{
    $payload = require_access_token('admin');

    if ($expectedDepartment !== null && ($payload['dep'] ?? '') !== $expectedDepartment) {
        json_response([
            'success' => false,
            'error' => 'You cannot access another department',
        ], 403);
    }

    return $payload;
}

function require_student(): array
{
    return require_access_token('student');
}
