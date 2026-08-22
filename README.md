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
- MySQL data storage
- JSON responses consumed by the Flutter application
- Spreadsheet dependency available through PhpSpreadsheet for student-data import workflows

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
├── main.dart
├── studentlogin.dart
├── adminlogin.dart
├── register.dart
├── message.dart
├── showmessage.dart
└── showmessageadmin.dart
php_files/               PHP backend endpoints
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

It contains only demo records and can be imported into MySQL for local testing.

## Local Setup

### 1. Flutter application

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

The current Flutter source is configured for Android Emulator local development and calls the PHP backend through `10.0.2.2`.

### 2. PHP backend

Place the `php_files` directory inside your local web server root, for example XAMPP `htdocs`.

Install the PHP dependency used by the spreadsheet import script:

```bash
cd php_files
composer install
```

### 3. MySQL

Create a database named `chat`, then import:

```text
database/student_notifications_demo.sql
```

The current PHP scripts use local-development database settings (`localhost`, `root`, empty password, database `chat`). Update these settings for your own environment before deployment.

## Portfolio Highlights

This project demonstrates hands-on experience with:

- Flutter mobile development
- PHP/MySQL backend integration
- HTTP requests and JSON handling
- Role-specific application flows
- Department- and level-based data filtering
- Form handling and validation workflows
- Arabic RTL mobile interfaces
- Relational data storage

## Notes

This repository is a portfolio/local-development project. Before production deployment, backend authentication and database access should be hardened further, environment-based configuration should be used, and all user input should be validated and parameterized.

## Author

**Rian Aldini**  
Full-Stack Web & Mobile Developer  
Flutter • Dart • PHP • MySQL
