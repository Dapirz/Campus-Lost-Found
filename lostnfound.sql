-- phpMyAdmin SQL Dump
-- version 6.0.0-dev+20251214.0422d4917c
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 01, 2026 at 12:07 AM
-- Server version: 8.4.3
-- PHP Version: 8.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lostnfound`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `claims`
--

CREATE TABLE `claims` (
  `id` bigint UNSIGNED NOT NULL,
  `report_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `proof_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `proof_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','approved','rejected','received') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `claim_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_04_03_000001_create_categories_table', 1),
(5, '2026_04_03_000002_create_reports_table', 1),
(6, '2026_04_03_000003_create_report_images_table', 1),
(7, '2026_04_03_000004_create_claims_table', 1),
(8, '2026_04_03_000005_create_notifications_table', 1),
(9, '2026_04_04_000001_drop_claims_table', 1),
(10, '2026_04_04_000002_update_status_enum_on_reports_table', 1),
(11, '2026_04_04_000003_add_admin_notes_to_reports_table', 1),
(12, '2026_04_04_000004_restore_rejected_status_on_reports_table', 1),
(13, '2026_04_10_014011_drop_categories_table_and_columns_v2', 1),
(14, '2026_04_23_030320_create_personal_access_tokens_table', 1),
(15, '2026_05_30_000000_create_claims_table', 1),
(16, '2026_05_30_000001_add_collection_pending_status_to_reports_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `message`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 5, 'report_verified', 'Your report \"KTM Fakultas Informatika\" has been verified and published.', 0, '2026-03-31 03:20:00', '2026-03-31 03:20:00'),
(2, 6, 'report_verified', 'Your report \"Earbuds Putih tanpa Case\" has been verified and published.', 0, '2026-03-30 08:45:00', '2026-03-30 08:45:00'),
(3, 2, 'report_verified', 'Your report \"Charger Laptop Hitam\" has been verified and published.', 0, '2026-03-29 04:35:00', '2026-03-29 04:35:00'),
(4, 4, 'report_verified', 'Your report \"Dompet Hitam dengan Kartu ATM\" has been verified and published.', 0, '2026-03-28 10:05:00', '2026-03-28 10:05:00'),
(5, 3, 'report_verified', 'Your report \"KTM dan KTP dalam Holder Transparan\" has been verified and published.', 0, '2026-03-27 06:40:00', '2026-03-27 06:40:00'),
(6, 5, 'report_verified', 'Your report \"Earbuds Case Abu-abu\" has been verified and published.', 0, '2026-03-26 07:25:00', '2026-03-26 07:25:00'),
(7, 6, 'report_rejected', 'Your report \"Kunci Loker Laboratorium\" has been rejected by the admin. Rejection reason: Foto tidak jelas dan deskripsi belum cukup untuk proses verifikasi.', 0, '2026-03-25 01:55:00', '2026-03-25 01:55:00');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 2, 'flutter-app', '5c6d84a663d07a4c504b0b08b8b3fa31132a29786a24ac441536cfcd4cf97a59', '[\"*\"]', '2026-05-31 17:05:39', NULL, '2026-05-31 17:04:18', '2026-05-31 17:05:39');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` enum('lost','found') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `location_text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `status` enum('pending','verified','resolved','rejected','collection_pending') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `admin_notes` text COLLATE utf8mb4_unicode_ci,
  `incident_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `user_id`, `type`, `title`, `description`, `location_text`, `latitude`, `longitude`, `status`, `admin_notes`, `incident_date`, `created_at`, `updated_at`) VALUES
(1, 2, 'lost', 'Dompet Kulit Cokelat', 'Dompet tertinggal setelah makan siang dan berisi kartu penting serta uang tunai.', 'Kantin FIF Lantai 1', -6.97385000, 107.63020000, 'pending', NULL, '2026-04-03', '2026-04-03 06:15:00', '2026-04-03 06:15:00'),
(2, 3, 'lost', 'Laptop ASUS VivoBook Biru', 'Laptop tertinggal setelah kelas praktikum dan terakhir terlihat di meja pojok dekat proyektor.', 'Gedung B Ruang 301', -6.97370000, 107.62985000, 'pending', NULL, '2026-04-02', '2026-04-02 02:15:00', '2026-04-02 02:15:00'),
(3, 4, 'found', 'Kunci Motor Honda dengan Gantungan Merah', 'Ditemukan di area parkir motor dekat jalur keluar masuk mahasiswa.', 'Parkiran Gedung A', -6.97405000, 107.63045000, 'pending', NULL, '2026-04-01', '2026-04-01 09:10:00', '2026-04-01 09:10:00'),
(4, 5, 'found', 'KTM Fakultas Informatika', 'Kartu mahasiswa ditemukan di lorong menuju perpustakaan dan masih dalam kondisi baik.', 'Perpustakaan Pusat Lt. 2', -6.97340000, 107.62950000, 'verified', NULL, '2026-03-31', '2026-03-31 03:20:00', '2026-03-31 03:20:00'),
(5, 6, 'found', 'Earbuds Putih tanpa Case', 'Earbuds ditemukan setelah acara seminar dan diletakkan sementara di meja registrasi.', 'Auditorium Universitas', -6.97325000, 107.62910000, 'verified', NULL, '2026-03-30', '2026-03-30 08:45:00', '2026-03-30 08:45:00'),
(6, 2, 'found', 'Charger Laptop Hitam', 'Charger ditemukan tergeletak di dekat stop kontak setelah ruang kelas kosong.', 'Gedung Tokong Nanas Ruang 210', -6.97392000, 107.62968000, 'verified', NULL, '2026-03-29', '2026-03-29 04:35:00', '2026-03-29 04:35:00'),
(7, 4, 'lost', 'Dompet Hitam dengan Kartu ATM', 'Dompet hilang saat menunggu kelas sore dan kemungkinan tertinggal di bangku area terbuka.', 'Selasar Gedung C', -6.97358000, 107.62996000, 'verified', NULL, '2026-03-28', '2026-03-28 10:05:00', '2026-03-28 10:05:00'),
(8, 3, 'lost', 'KTM dan KTP dalam Holder Transparan', 'Holder kartu hilang setelah salat dzuhur dan terakhir terlihat di rak sepatu dekat pintu masuk.', 'Masjid Kampus', -6.97415000, 107.62925000, 'resolved', NULL, '2026-03-27', '2026-03-27 06:40:00', '2026-03-27 06:40:00'),
(9, 5, 'found', 'Earbuds Case Abu-abu', 'Case earbuds ditemukan di meja baca dan sudah diserahkan kembali ke pemiliknya.', 'Open Library Area Diskusi', -6.97330000, 107.62942000, 'resolved', NULL, '2026-03-26', '2026-03-26 07:25:00', '2026-03-26 07:25:00'),
(10, 6, 'lost', 'Kunci Loker Laboratorium', 'Kunci hilang, tetapi foto yang diunggah tidak jelas dan informasi ciri fisik kunci sangat minim.', 'Laboratorium Multimedia Gedung A', -6.97396000, 107.63008000, 'rejected', 'Foto tidak jelas dan deskripsi belum cukup untuk proses verifikasi.', '2026-03-25', '2026-03-25 01:55:00', '2026-03-25 01:55:00');

-- --------------------------------------------------------

--
-- Table structure for table `report_images`
--

CREATE TABLE `report_images` (
  `id` bigint UNSIGNED NOT NULL,
  `report_id` bigint UNSIGNED NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_images`
--

INSERT INTO `report_images` (`id`, `report_id`, `image_url`, `created_at`, `updated_at`) VALUES
(1, 10, 'http://localhost/storage/reports/dummy-1.jpg', '2026-03-25 01:55:00', '2026-03-25 01:55:00'),
(2, 9, 'http://localhost/storage/reports/dummy-2.jpg', '2026-03-26 07:25:00', '2026-03-26 07:25:00'),
(3, 8, 'http://localhost/storage/reports/dummy-3.jpg', '2026-03-27 06:40:00', '2026-03-27 06:40:00'),
(4, 7, 'http://localhost/storage/reports/dummy-4.jpg', '2026-03-28 10:05:00', '2026-03-28 10:05:00'),
(5, 6, 'http://localhost/storage/reports/dummy-5.jpg', '2026-03-29 04:35:00', '2026-03-29 04:35:00'),
(6, 5, 'http://localhost/storage/reports/dummy-1.jpg', '2026-03-30 08:45:00', '2026-03-30 08:45:00'),
(7, 4, 'http://localhost/storage/reports/dummy-2.jpg', '2026-03-31 03:20:00', '2026-03-31 03:20:00'),
(8, 3, 'http://localhost/storage/reports/dummy-3.jpg', '2026-04-01 09:10:00', '2026-04-01 09:10:00'),
(9, 2, 'http://localhost/storage/reports/dummy-4.jpg', '2026-04-02 02:15:00', '2026-04-02 02:15:00'),
(10, 1, 'http://localhost/storage/reports/dummy-5.jpg', '2026-04-03 06:15:00', '2026-04-03 06:15:00');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('Ad0X41XcGldTVT5Ty3wlNvFCS4NctmRHX2TOUf4a', NULL, '127.0.0.1', 'Dart/3.11 (dart:io)', 'eyJfdG9rZW4iOiJjT0U0MWRvN1hjYzNkbDRWZGxQYXF6RmdZNXByb1Z6OW5MVVM3Q0NkIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEwLjAuMi4yOjgwMDBcL3N0b3JhZ2VcL3JlcG9ydHNcL2R1bW15LTUuanBnIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1780272260),
('MciVU1spQFmMPvth6q3fSMwfVCVeOBiA5T9hhaNF', NULL, '127.0.0.1', 'Dart/3.11 (dart:io)', 'eyJfdG9rZW4iOiJydUgzTDc0WW41ZkZQekx0bUxuRm1lYmpMTXU3YzJ0WDEyNzNOMU80IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEwLjAuMi4yOjgwMDBcL3N0b3JhZ2VcL3JlcG9ydHNcL2R1bW15LTIuanBnIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1780272261),
('mO2g1nd8tMoXvYTuUKq3lfdg3CR41sg4GCpivszD', NULL, '127.0.0.1', 'Dart/3.11 (dart:io)', 'eyJfdG9rZW4iOiJnOXpNUDBFUzlMa3p4c0RhdkJob3k1ZlNGZVhSWXRlYzBETk0wZmYzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEwLjAuMi4yOjgwMDBcL3N0b3JhZ2VcL3JlcG9ydHNcL2R1bW15LTQuanBnIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1780272261),
('P4irtmg5W0gx3AAY6MJHJR7sjp8EJesEoKoqQWVD', NULL, '127.0.0.1', 'Dart/3.11 (dart:io)', 'eyJfdG9rZW4iOiJpZU5kc3VVeHZsYXd6QzlTaFpJZ0hJbkhjQTJjZ1BTZm9DRmRwc0FvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEwLjAuMi4yOjgwMDBcL3N0b3JhZ2VcL3JlcG9ydHNcL2R1bW15LTEuanBnIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1780272261),
('p75MnqGzbUybsGpieOdCJZtWlaqOzlgXiJAX9xt9', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJNeHg1cFNBcGRqZ1Z6ajYwb1R5dVVaR1p5T3UxSDJRVE1Dc2N5WDJoIiwiX2ZsYXNoIjp7Im5ldyI6W10sIm9sZCI6W119LCJfcHJldmlvdXMiOnsidXJsIjoiaHR0cDpcL1wvMTI3LjAuMC4xOjgwMDBcL2FkbWluXC9yZXBvcnRzXC8xIiwicm91dGUiOiJhZG1pbi5yZXBvcnRzLnNob3cifSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjF9', 1780271891);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `fcm_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `fcm_token`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Campus Admin', 'admin@campuslostfound.com', NULL, '$2y$12$ZAVcaAWdi5lQSBizCvelaeLcPAFN6ZczM9a5hK0IuWcjIRBBhlUtm', 'admin', 1, NULL, NULL, '2026-05-31 16:51:52', '2026-05-31 16:51:52'),
(2, 'Budi Santoso', 'budi@student.telkomuniversity.ac.id', NULL, '$2y$12$YLMKvAGLlvqc8GR.aXIiYOEOV3y2D7VNUrLL6kS/2U2g73dHo7H3y', 'user', 1, 'ckXc2Y2lTiKhQAqDJnDpzB:APA91bGt5xxo3n-65HX-pX3Pu8sx4b7kX52P3COz6qzdC6iG8Z8FWq5T7Y1iPYizSePs3vNqcSvGlHnxKWLEuePp6rmVJG3b1NN5CcRoVDkTx0k3Cu5y8io', NULL, '2026-05-31 16:51:53', '2026-05-31 17:04:19'),
(3, 'Siti Aminah', 'siti@student.telkomuniversity.ac.id', NULL, '$2y$12$CJjfkd9X62FXjnkqe7963.X1tbpUgLvUHzYld7htOALGpjMQJVy4u', 'user', 1, NULL, NULL, '2026-05-31 16:51:53', '2026-05-31 16:51:53'),
(4, 'Andi Pratama', 'andi@student.telkomuniversity.ac.id', NULL, '$2y$12$RV2xGna3fwejYW53idJgzu0Uf4JUlI50Nw6O8WMB.fQ7VnhxxZt/e', 'user', 1, NULL, NULL, '2026-05-31 16:51:53', '2026-05-31 16:51:53'),
(5, 'Farah Nabila', 'farah@student.telkomuniversity.ac.id', NULL, '$2y$12$IuV35t0he4zs51IaLhqCaeFWSKLESC8DD4/C6/Lm83oG1UARPnDUC', 'user', 1, NULL, NULL, '2026-05-31 16:51:53', '2026-05-31 16:51:53'),
(6, 'Cahyo Nugroho', 'cahyo@student.telkomuniversity.ac.id', NULL, '$2y$12$zNXMhlOJaAXEIBzCGjnLBOTZ.D2zwvIKks.73VgSYiWWR1n9NXQ/6', 'user', 1, NULL, NULL, '2026-05-31 16:51:53', '2026-05-31 16:51:53');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `claims`
--
ALTER TABLE `claims`
  ADD PRIMARY KEY (`id`),
  ADD KEY `claims_report_id_foreign` (`report_id`),
  ADD KEY `claims_user_id_foreign` (`user_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reports_user_id_foreign` (`user_id`);

--
-- Indexes for table `report_images`
--
ALTER TABLE `report_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `report_images_report_id_foreign` (`report_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `claims`
--
ALTER TABLE `claims`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `report_images`
--
ALTER TABLE `report_images`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `claims`
--
ALTER TABLE `claims`
  ADD CONSTRAINT `claims_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `claims_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `report_images`
--
ALTER TABLE `report_images`
  ADD CONSTRAINT `report_images_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
