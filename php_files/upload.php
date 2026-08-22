<?php

declare(strict_types=1);

use PhpOffice\PhpSpreadsheet\Reader\Xlsx;

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/vendor/autoload.php';

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
} catch (Throwable $exception) {
    json_response([
        'success' => false,
        'error' => 'Unable to read the uploaded XLSX file',
    ], 422);
}

$connection = db_connection();
$statement = prepared_statement(
    $connection,
    'INSERT INTO student (code, fullname, dep, level) VALUES (?, ?, ?, ?)'
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
    $department = $values[2] ?? '';
    $level = $values[3] ?? '';

    if ($code === '' || $fullname === '' || $department === '' || !valid_level($level, false)) {
        $skipped++;
        continue;
    }

    $check = prepared_statement($connection, 'SELECT id FROM student WHERE code = ? LIMIT 1');
    $check->bind_param('s', $code);
    $check->execute();
    $check->store_result();

    if ($check->num_rows > 0) {
        $check->close();
        $skipped++;
        continue;
    }

    $check->close();
    $statement->bind_param('ssss', $code, $fullname, $department, $level);

    if ($statement->execute()) {
        $inserted++;
    } else {
        $skipped++;
    }
}

$statement->close();

json_response([
    'success' => true,
    'inserted' => $inserted,
    'skipped' => $skipped,
]);
