# Student Notification Mobile System

A mobile student-notification system built with **Flutter**, **Dart**, **PHP**, and **MySQL**. The project provides separate student and administrator flows and allows academic messages to be targeted by department and study level.

## Overview

The Flutter application communicates with a lightweight PHP/MySQL backend over HTTP. Students can sign in using their registration code and view messages assigned to their department and level. Administrators can sign in, add students, send announcements, and review previously sent messages.

## Key Features

### Student
- Student login using registration code
- Department- and level-based message access
- Arabic RTL interface
- Message history with timestamps

### Administrator
- Administrator login
- Department-specific workflow
- Add students with registration code, department, and level
- Send messages to L1, L2, L3, L4, or all levels
- View sent messages

### Backend
- PHP endpoints for login, registration, messaging, and message retrieval
- Centralized database/API configuration in `php_files/config.php`
- Prepared statements for user-controlled database queries
- MySQL `utf8mb4` connection handling
- JSON responses consumed by the Flutter application
- Password-hash support for administrator accounts
- XLSX student import through PhpSpreadsheet with validation

### Flutter API Configuration
- All Flutter API endpoints are built from `lib/api_config.dart`
- No endpoint URL is duplicated across screens
- Local Android Emulator development works by default through `10.0.2.2`
- Real-device and production API URLs can be supplied with `--dart-define`

## Tech Stack

- **Mobile:** Flutter, Dart
- **Backend:** PHP
- **Database:** MySQL
- **Communication:** HTTP / JSON
- **Flutter Packages:** http, intl, chat_bubbles
- **PHP Package:** PhpSpreadsheet

## Project Structure

```text
android/                 Android application files
ios/                     iOS application files
lib/                     Flutter application source
├── api_config.dart      Central Flutter API configuration
├── main.dart
├── studentlogin.dart
├── adminlogin.dart
├── register.dart
├── message.dart
├── show.dart
├── showmessage.dart
└── showmessageadmin.dart
php_files/               PHP backend endpoints
├── config.php           Shared DB/API configuration
├── login.php
├── studentlogin.php
├── register.php
├── message.php
├── showmessage.php
├── showadmin.php
├── checkcode.php
├── upload.php
├── composer.json
└── composer.lock
database/                Safe demo database schema
```

## Demo Database

A sanitized demo schema is included at:

```text
database/student_notifications_demo.sql
```

It contains only demo records and can be imported into MySQL for local testing. The demo administrator password is stored as a bcrypt hash.

## Local Setup

### 1. Flutter application

Install dependencies:

```bash
flutter pub get
```

For the Android Emulator, the default configuration already points to:

```text
http://10.0.2.2/php_files
```

Run normally:

```bash
flutter run
```

For a physical phone on the same local network, pass the computer's LAN address:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/php_files
```

For production, use your HTTPS API URL:

```bash
flutter run --dart-define=API_BASE_URL=https://example.com/php_files
```

The URL is configured once in `lib/api_config.dart`, and every Flutter screen uses `ApiConfig.endpoint(...)`.

### 2. PHP backend

Place the `php_files` directory inside your local web server root, for example XAMPP `htdocs`.

Install the PHP dependency used by the spreadsheet import script:

```bash
cd php_files
composer install
```

Database settings are centralized in `php_files/config.php`. For local XAMPP development the defaults are:

```text
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=chat
```

For deployment, set these values as server environment variables instead of hard-coding production credentials.

### 3. MySQL

Create/import the demo database using:

```text
database/student_notifications_demo.sql
```

## Backend Safety Improvements

The portfolio version of the backend uses prepared statements instead of interpolating user input directly into SQL. API responses no longer expose administrator passwords, student registration is validated, duplicate registration codes are rejected, and XLSX imports validate file type, size, and row data before insertion.

The login endpoint supports bcrypt/Argon password hashes. A temporary plaintext-password compatibility path remains only so older local databases can still be tested; new deployments should use password hashes exclusively.

## Flutter Cleanup Improvements

The Flutter layer now has one configurable API base URL, consistent JSON parsing, cleaner error handling, and removed duplicated hard-coded backend addresses. The legacy chat screen was also aligned with the JSON response returned by the PHP backend.

## Portfolio Highlights

This project demonstrates hands-on experience with:

- Flutter mobile development
- PHP/MySQL backend integration
- HTTP requests and JSON handling
- Role-specific application flows
- Department- and level-based data filtering
- Centralized Flutter API configuration
- Runtime environment configuration with `--dart-define`
- Prepared statements and backend input validation
- Centralized backend configuration
- Password-hash verification
- XLSX data import
- Arabic RTL mobile interfaces
- Relational data storage

## Notes

This repository is a portfolio/local-development project. Before public deployment, use HTTPS, production environment variables, stronger authorization/session handling, and request rate limiting.

## Author

**Rian Aldini**  
Full-Stack Web & Mobile Developer  
Flutter • Dart • PHP • MySQL
