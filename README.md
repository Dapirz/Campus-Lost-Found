# 🔍 Campus Lost & Found

A full-stack **Lost & Found** management system for university campuses. Built with **Laravel** (Backend API + Admin Panel) and **Flutter** (Mobile App).

> **Course Project — Platform-Based Application Development**  
> Telkom University © 2026 — Group 1 JOSSJISS

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Default Accounts](#default-accounts)
- [API Endpoints](#api-endpoints)
- [Team](#team)

---

## Overview

Campus Lost & Found is a platform that helps students and staff report lost or found items on campus. The system consists of:

- **Admin Panel (Web)** — For administrators to manage reports, verify/reject submissions, review ownership claims, generate claim codes, and manage user accounts.
- **Mobile App (Flutter)** — For students to browse reports, submit lost/found items, claim items by submitting ownership proofs, track their active claims with real-time status cards, receive notifications, and confirm receipt of items.

---

## Features

### 🌐 Admin Panel (Laravel Blade)

- 📊 Dashboard with report statistics
- 📝 Report management (verify, reject, delete)
- 👥 User management (activate/deactivate, delete)
- 🔐 Admin authentication
- 🖼️ Image preview for report submissions
- 🚨 **Claim Verification System** — Beautiful dialog modals to review claimant's proof and approve/reject claims, complete with a dynamic pending claims counter badge.
- 🔑 **Claim Code Generator** — Automatically generates a secure 6-digit Claim Code (e.g. `LF-XXXXXX`) and changes the report status to `Collection Pending` upon approval, hiding it from the public feed.

### 📱 Mobile App (Flutter)

- 🏠 Home feed with search & filter (Lost/Found/All)
- 📸 Create report with image upload
- 📄 Detailed report view with image gallery
- 📋 My Reports — track personal submissions by status
- 👤 Profile — stats, edit profile, change password (fully localized in English)
- 📬 Inbox — in-app notifications with read/unread states (automatically translated from backend)
- 🔐 Authentication (Login/Register) with token persistence
- ✅ Mark reports as resolved
- 🛡️ **Secure Claim Process** — Submit ownership description and supporting photo proofs (optional) to request a claim.
- 🎨 **HSL Status Cards** — Informative, visually premium color-coded cards for active claims (Yellow for Pending, Red for Rejected, Green for Approved containing the large Claim Code, and Forest Green for Received).
- 🤝 **Self-Service Physical Handover** — Present the Claim Code to campus security (Satpam) and click the click-locked "Confirm I Received the Item" button to resolve the process physically and digitally.

---

## Tech Stack

### Backend

| Technology | Version |
|------------|---------|
| PHP | ^8.3 |
| Laravel | ^13.0 |
| Laravel Sanctum | ^4.3 |
| MySQL | 8.x |
| Blade Templates | — |

### Mobile

| Technology | Version |
|------------|---------|
| Flutter | ^3.11 |
| Dart | ^3.11.4 |
| Provider | ^6.1.5 |
| HTTP | ^1.6.0 |
| SharedPreferences | ^2.5.5 |
| ImagePicker | ^1.2.1 |

---

## Project Structure

```
Campus-Lost-Found/
├── laravel/                    # Backend (API + Admin Panel)
│   ├── app/
│   │   ├── Http/Controllers/
│   │   │   ├── Api/            # REST API controllers
│   │   │   │   ├── AuthController.php
│   │   │   │   ├── ReportController.php
│   │   │   │   ├── NotificationController.php
│   │   │   │   ├── UserProfileController.php
│   │   │   │   └── ClaimController.php     # Handles mobile claims and handover
│   │   │   ├── AdminAuthController.php
│   │   │   ├── AdminDashboardController.php
│   │   │   ├── AdminReportController.php   # Handles claim verification & status
│   │   │   └── AdminUserController.php
│   │   └── Models/
│   │       ├── Claim.php       # Claim Eloquent Model
│   │       └── Report.php
│   ├── database/
│   │   ├── migrations/         # Includes create_claims_table migration
│   │   └── seeders/
│   ├── resources/views/admin/  # Blade templates
│   ├── routes/
│   │   ├── api.php             # Mobile API routes
│   │   └── web.php             # Admin panel routes
│   └── public/images/          # Static assets
│
└── campus_lost_found/          # Flutter Mobile App
    └── lib/
        ├── config/             # API config, color palette, translation engine
        ├── models/             # Data models (including ReportActiveClaimModel)
        ├── providers/          # State management (Provider)
        ├── services/           # API service layer (with auto token injection)
        ├── screens/
        │   ├── auth/           # Login, Register
        │   ├── home/           # Home feed
        │   ├── report/         # Report detail, create, my reports, claim dialog
        │   ├── profile/        # Profile, edit profile (fully localized)
        │   └── notification/   # Inbox
        └── widgets/            # Reusable components
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **PHP** >= 8.3
- **Composer** >= 2.x
- **MySQL** >= 8.x (or MariaDB)
- **Node.js** >= 18.x (for Vite asset compilation)
- **Flutter SDK** >= 3.11
- **Android Studio** / **VS Code** with Flutter extension
- **Android Emulator** or physical device

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Dapirz/Campus-Lost-Found.git
cd Campus-Lost-Found
```

### 2. Setup Laravel Backend

```bash
cd laravel

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=lostnfound
# DB_USERNAME=root
# DB_PASSWORD=

# Create the database
mysql -u root -e "CREATE DATABASE IF NOT EXISTS lostnfound"

# Run migrations and seeders (Option A - Standard Seed)
php artisan migrate --seed

# OR Import the ready-to-use database directly (Option B - SQL Import)
# 1. Run migrations only to prepare the tables:
php artisan migrate
# 2. Import the provided 'lostnfound.sql' file from the root directory via terminal:
# mysql -u root lostnfound < ../lostnfound.sql
# (Or import it via phpMyAdmin interface into the 'lostnfound' database)

# Create storage symlink (Option A - Windows Automatic Helper Script)
# If you are on Windows, simply double-click the 'setup-storage.bat' helper file in the root directory. 
# It will automatically request Administrator privileges, clean any broken symlinks, and link the storage folder natively!

# OR Create storage symlink (Option B - Standard Artisan Command)
php artisan storage:link

# Start the server (Accessible locally and externally from mobile device)
php artisan serve --host=0.0.0.0 --port=8000
```

> The backend will run at `http://127.0.0.1:8000` or your local machine IP address.

### 3. Setup Firebase Cloud Messaging (FCM)

This application uses Firebase for push notifications.

1. **Frontend (Flutter)**: The `google-services.json` configuration is already included in the repository (`campus_lost_found/android/app/google-services.json`).
2. **Backend (Laravel)**: The server requires a Service Account JSON file to have access rights to send notifications from Laravel.
   - Create a `firebase-credentials.json` file inside the `laravel/storage/app/` directory (This file is ignored by Git for security reasons).
   - Ensure the path in `.env` is correct: `FIREBASE_CREDENTIALS_PATH="D:/ProjectABP/Campus-Lost-Found/laravel/storage/app/firebase-credentials.json"` or adjust it to your own PC path.

### 4. Setup Flutter Mobile App

```bash
cd campus_lost_found

# Get dependencies
flutter pub get

# Run on emulator or connected device
flutter run
```

> **Note:** The Flutter app is configured to connect to `http://10.0.2.2:8000` (Android emulator's alias for host `localhost`). If using a physical device, update `lib/config/api_config.dart` with your machine's local IP address.

---

## Default Accounts

After running `php artisan migrate --seed`, the following accounts are available:

### Admin (Web Panel)

| Email | Password |
|-------|----------|
| `admin@campuslostfound.com` | `admin123` |

> Access the admin panel at: `http://127.0.0.1:8000/admin/login`

### Students (Mobile App)

| Name | Email | Password |
|------|-------|----------|
| Budi Santoso | `budi@student.telkomuniversity.ac.id` | `password123` |
| Siti Aminah | `siti@student.telkomuniversity.ac.id` | `password123` |
| Andi Pratama | `andi@student.telkomuniversity.ac.id` | `password123` |
| Farah Nabila | `farah@student.telkomuniversity.ac.id` | `password123` |
| Cahyo Nugroho | `cahyo@student.telkomuniversity.ac.id` | `password123` |

---

## API Endpoints

### Public (No Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/register` | Register new user |
| `POST` | `/api/auth/login` | Login & get token |
| `GET` | `/api/reports` | List verified reports (supports authorized user filtering) |
| `GET` | `/api/reports/{id}` | Report detail (supports authorized user claims parsing) |

### Protected (Bearer Token Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/logout` | Logout |
| `GET` | `/api/auth/me` | Get current user |
| `GET` | `/api/reports/my` | Get user's reports |
| `POST` | `/api/reports` | Create new report |
| `DELETE` | `/api/reports/{id}` | Delete a report |
| `PATCH` | `/api/reports/{id}/resolve` | Mark as resolved |
| `GET` | `/api/user/profile` | Get profile |
| `PUT` | `/api/user/profile` | Update profile |
| `GET` | `/api/notifications` | Get notifications |
| `PATCH` | `/api/notifications/{id}/read` | Mark notification as read |
| `POST` | `/api/reports/{id}/claim` | Submit ownership claim request (multipart file proof support) |
| `PATCH` | `/api/claims/{id}/confirm` | Confirm physical receipt of claim (self-service handover) |

---

## Team

**Group 1 — JOSSJISS**

Telkom University — Platform-Based Application Development 2026

---

## License

This project is developed for educational purposes as part of the **Platform-Based Application Development** course at Telkom University.
