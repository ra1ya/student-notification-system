# Student Notification Mobile System

A secure multi-role student notification application built with **Flutter**, **Dart**, **PHP 8.2**, and **MySQL**. The project demonstrates mobile/backend integration, role-based authorization, signed access tokens, prepared SQL statements, environment-based configuration, automated quality checks, and Arabic RTL user flows.

## What the System Does

Students sign in with their registration code and receive announcements for their department and study level. Administrators authenticate separately, add students, send targeted announcements, review sent messages, and optionally import student data from XLSX files.

## Key Features

- Separate student and administrator authentication flows
- Signed HMAC access tokens with role and expiry validation
- Department-level authorization for administrator actions
- Level-targeted announcements (`L1`–`L4` or all levels)
- Student message access derived from the authenticated token, not client-provided filters
- Prepared statements for database queries
- bcrypt password verification for administrators
- Server-generated message timestamps
- XLSX student import with validation and department restrictions
- Centralized Flutter API client and runtime API URL configuration
- Loading, empty, retry, and error states in the Flutter UI
- Arabic RTL interface
- Sanitized demo database
- GitHub Actions for `flutter analyze`, `flutter test`, and PHP syntax checks

## Architecture

```text
Flutter App
   │
   │ HTTP / JSON + Bearer token
   ▼
PHP API
   │
   ├── Authentication & authorization
   ├── Input validation
   ├── Prepared statements
   │
   ▼
MySQL
```

The API URL is configured once in `lib/api_config.dart`. Shared request handling and authentication headers live in `lib/api_client.dart`.

## Tech Stack

- **Mobile:** Flutter, Dart
- **Backend:** PHP 8.2+
- **Database:** MySQL / MariaDB
- **API:** HTTP, JSON, Bearer authentication
- **Security:** bcrypt, HMAC-SHA256 signed access tokens, prepared statements
- **Quality:** Flutter analyzer, widget tests, PHP syntax linting, GitHub Actions
- **Spreadsheet Import:** PhpSpreadsheet

## Project Structure

```text
lib/
├── api_config.dart
├── api_client.dart
├── main.dart
├── studentlogin.dart
├── adminlogin.dart
├── register.dart
├── message.dart
├── showmessage.dart
└── showmessageadmin.dart

php_files/
├── config.php
├── login.php
├── studentlogin.php
├── register.php
├── message.php
├── showmessage.php
├── showadmin.php
├── upload.php
├── composer.json
└── composer.lock

database/
└── student_notifications_demo.sql

.github/workflows/
└── quality.yml
```

## Local Setup

### Flutter

Install dependencies:

```bash
flutter pub get
```

For the Android Emulator, the default backend URL is:

```text
http://10.0.2.2/php_files
```

Run normally:

```bash
flutter run
```

For a physical phone or another API server:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/php_files
```

For production:

```bash
flutter run --dart-define=API_BASE_URL=https://example.com/php_files
```

### PHP Backend

Place `php_files` in your PHP web root and install Composer dependencies:

```bash
cd php_files
composer install
```

Configure these environment variables on the server:

```text
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=chat
APP_KEY=replace-with-a-long-random-production-secret
```

`APP_KEY` signs access tokens. The repository contains a local-development fallback only so the demo can run without additional setup; production deployments must provide their own secret.

### MySQL

Import the sanitized demo database:

```text
database/student_notifications_demo.sql
```

Demo administrator credentials:

```text
Username: demo_admin
Password: password
```

The password is stored as a bcrypt hash in the SQL file.

## Security Design

Administrator passwords are never returned by the API. Successful login issues a short-lived signed token containing only the minimum authorization claims. Protected endpoints validate token signature, role, expiry, and administrator department before processing a request.

Student message retrieval also requires a signed student token. Department and level are taken from validated token claims, preventing the client from requesting another student's message scope simply by changing request parameters.

Database queries use prepared statements and user-controlled text is length-validated. Production deployment should additionally use HTTPS, a strong `APP_KEY`, web-server rate limiting, and normal infrastructure hardening.

## Quality Checks

The repository includes a GitHub Actions workflow that runs on pushes and pull requests to `main`:

```text
flutter pub get
flutter analyze
flutter test
php -l php_files/*.php
```

The included widget test verifies the student login screen renders its core controls.

## Portfolio Highlights

This project demonstrates practical experience with Flutter application development, PHP/MySQL backend engineering, API integration, authentication and authorization, secure database access, environment configuration, automated quality checks, responsive error handling, and maintainable project organization.

## Author

**Rian Aldini**  
Full-Stack Web & Mobile Developer  
Flutter • Dart • PHP • MySQL
