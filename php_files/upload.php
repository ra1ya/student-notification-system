<?php

declare(strict_types=1);

use PhpOffice\PhpSpreadsheet\Reader\Xlsx;

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/vendor/autoload.php';

$admin = require_admin();
$adminDepartment = (string) ($admin['dep'] ?? '');

if ($adminDepartment === '') {
    json_response([
        'success' => false,
        'error' => 'Invalid administrator token',
    ], 401);
}

if (!isset($_FILES['excel_file'])) {
    json_response([
        'success' => false,
        'error' => 'No file was uploaded',
    ], 400);
}

$file = $_FILES['excel_file'];

if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
    json_response([
        'success' => false,
        'error' => 'File upload failed',
    ], 400);
}

$fileName = (string) ($file['name'] ?? '');
$fileSize = (int) ($file['size'] ?? 0);
$fileTmp = (string) ($file['tmp_name'] ?? '');
$extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if ($extension !== 'xlsx') {
    json_response([
        'success' => false,
        'error' => 'Only XLSX files are supported',
    ], 422);
}

if ($fileSize <= 0 || $fileSize > 5 * 1024 * 1024) {
    json_response([
        'success' => false,
        'error' => 'The XLSX file must be 5 MB or smaller',
    ], 422);
}

try {
    $reader = new Xlsx();
    $spreadsheet = $reader->load($fileTmp);
    $worksheet = $spreadsheet->getActiveSheet();
} catch (Throwable) {
    json_response([
        'success' => false,
        'error' => 'Unable to read the uploaded XLSX file',
    ], 422);
}

$connection = db_connection();
$insert = prepared_statement(
    $connection,
    'INSERT INTO student (code, fullname, dep, level) VALUES (?, ?, ?, ?)'
);
$exists = prepared_statement(
    $connection,
    'SELECT id FROM student WHERE code = ? LIMIT 1'
);

$inserted = 0;
$skipped = 0;

foreach ($worksheet->getRowIterator(3) as $row) {
    $values = [];
    $cellIterator = $row->getCellIterator();
    $cellIterator->setIterateOnlyExistingCells(false);

    foreach ($cellIterator as $cell) {
        $values[] = trim((string) $cell->getValue());
    }

    $code = $values[0] ?? '';
    $fullname = $values[1] ?? '';
    $rowDepartment = $values[2] ?? '';
    $level = $values[3] ?? '';

    if ($code === ''
        || $fullname === ''
        || $rowDepartment !== $adminDepartment
        || !valid_level($level, false)) {
        $skipped++;
        continue;
    }

    $exists->bind_param('s', $code);
    $exists->execute();
    $exists->store_result();

    if ($exists->num_rows > 0) {
        $exists->free_result();
        $skipped++;
        continue;
    }

    $exists->free_result();
    $insert->bind_param('ssss', $code, $fullname, $adminDepartment, $level);

    if ($insert->execute()) {
        $inserted++;
    } else {
        $skipped++;
    }
}

$exists->close();
$insert->close();

json_response([
    'success' => true,
    'inserted' => $inserted,
    'skipped' => $skipped,
]);
