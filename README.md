# 🔍 Campus Lost & Found

A full-stack **Lost & Found** management system for university campuses. Built with **Laravel** (Backend API + Admin Panel) and **Flutter** (Mobile App).

> **Tugas Besar — Aplikasi Berbasis Platform**  
> Telkom University © 2026 — Kelompok 1 JOSSJISS

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
- [Screenshots](#screenshots)
- [Team](#team)

---

## Overview

Campus Lost & Found is a platform that helps students and staff report lost or found items on campus. The system consists of:

- **Admin Panel (Web)** — For administrators to manage reports, verify/reject submissions, and manage user accounts.
- **Mobile App (Flutter)** — For students to browse reports, submit lost/found items, track their reports, and receive notifications.

---

## Features

### 🌐 Admin Panel (Laravel Blade)
- 📊 Dashboard with report statistics
- 📝 Report management (verify, reject, delete)
- 👥 User management (activate/deactivate, delete)
- 🔐 Admin authentication
- 🖼️ Image preview for report submissions

### 📱 Mobile App (Flutter)
- 🏠 Home feed with search & filter (Lost/Found/All)
- 📸 Create report with image upload
- 📄 Detailed report view with image gallery
- 📋 My Reports — track personal submissions by status
- 👤 Profile — stats, edit profile, change password
- 📬 Inbox — in-app notifications with read/unread states
- 🔐 Authentication (Login/Register) with token persistence
- ✅ Mark reports as resolved

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
│   │   │   │   └── UserProfileController.php
│   │   │   ├── AdminAuthController.php
│   │   │   ├── AdminDashboardController.php
│   │   │   ├── AdminReportController.php
│   │   │   └── AdminUserController.php
│   │   └── Models/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── resources/views/admin/  # Blade templates
│   ├── routes/
│   │   ├── api.php             # Mobile API routes
│   │   └── web.php             # Admin panel routes
│   └── public/images/          # Static assets
│
└── campus_lost_found/          # Flutter Mobile App
    └── lib/
        ├── config/             # API config, color palette
        ├── models/             # Data models
        ├── providers/          # State management (Provider)
        ├── services/           # API service layer
        ├── screens/
        │   ├── auth/           # Login, Register
        │   ├── home/           # Home feed
        │   ├── report/         # Report detail, create, my reports
        │   ├── profile/        # Profile, edit profile
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

# Run migrations and seeders
php artisan migrate --seed

# Create storage symlink
php artisan storage:link

# Start the server
php artisan serve
```

> The backend will run at `http://127.0.0.1:8000`

### 3. Setup Flutter Mobile App

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
| `GET` | `/api/reports` | List verified reports |
| `GET` | `/api/reports/{id}` | Report detail |

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

---

## Screenshots

> *Screenshots will be added here*

<!-- 
### Mobile App
| Login | Home | Report Detail |
|-------|------|---------------|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) |

### Admin Panel
| Dashboard | Reports | Users |
|-----------|---------|-------|
| ![Dashboard](screenshots/dashboard.png) | ![Reports](screenshots/reports.png) | ![Users](screenshots/users.png) |
-->

---

## Team

**Kelompok 1 — JOSSJISS**

Telkom University — Aplikasi Berbasis Platform 2026

---

## License

This project is developed for educational purposes as part of the **Platform-Based Application Development** course at Telkom University.
