**API CONTRACT**

**Campus Lost & Found**

REST API Reference untuk Flutter Mobile Client

Kelompok 1 | IF-47-09 | Universitas Telkom 2026

# **Konvensi & Aturan Umum**

## **Base URL**

http://&lt;server-ip&gt;/api

Semua endpoint di bawah ini menggunakan prefix /api. Contoh lengkap:

<http://192.168.1.10/api/auth/login>

## **Authentication**

Web Admin menggunakan Laravel Session (cookie). Flutter menggunakan Laravel Sanctum token.

Setelah login via API, simpan token di Flutter dan kirim di setiap request yang butuh auth:

Authorization: Bearer &lt;sanctum_token&gt;

Tiga level akses yang digunakan di dokumen ini:

- Public - tidak perlu token, siapa saja bisa akses
- User (Sanctum) - harus login sebagai mahasiswa, kirim Bearer token
- Admin (Session) - khusus web admin, autentikasi via Laravel Session

## **Format Response**

Semua response dalam format JSON. Struktur standar sukses:

{

"success": true,

"message": "...",

"data": { ... }

}

Struktur standar error:

{

"success": false,

"message": "Pesan error",

"errors": { "field": \["..."\] }

}

## **HTTP Status Code yang Digunakan**

| **Code** | **Status**    | **Kapan digunakan**                               |
| -------- | ------------- | ------------------------------------------------- |
| **200**  | OK            | Request berhasil - GET, PUT, PATCH                |
| **201**  | Created       | Resource berhasil dibuat - POST                   |
| **204**  | No Content    | Berhasil hapus, tidak ada response body - DELETE  |
| **401**  | Unauthorized  | Token tidak ada atau expired                      |
| **403**  | Forbidden     | Token ada tapi tidak punya hak akses              |
| **404**  | Not Found     | Resource tidak ditemukan                          |
| **422**  | Unprocessable | Validasi gagal - ada field yang salah atau kurang |
| **500**  | Server Error  | Bug di server - laporkan ke backend dev           |

# **1\. Authentication**

Endpoint autentikasi untuk Flutter mobile client menggunakan Laravel Sanctum.

**POST /api/auth/register**

Registrasi akun mahasiswa baru. Email harus aktif dan belum terdaftar.

**Auth: Public**

**Request Body (JSON):**

| **Field**             | **Type** | **Required** | **Keterangan**             |
| --------------------- | -------- | ------------ | -------------------------- |
| name                  | string   | ✓ Ya         | Nama lengkap pengguna      |
| email                 | string   | ✓ Ya         | Email aktif, harus unik    |
| password              | string   | ✓ Ya         | Minimal 8 karakter         |
| password_confirmation | string   | ✓ Ya         | Harus sama dengan password |

**Responses:**

**201** - Registrasi berhasil

{

"success": true,

"message": "Registrasi berhasil",

"data": {

"user": { "id": 1, "name": "Daffa", "email": "<daffa@student.telkomuniversity.ac.id>" }

}

}

**422** - Validasi gagal (email sudah dipakai, password tidak cocok, dll)

{

"success": false,

"message": "Validasi gagal",

"errors": { "email": \["Email sudah terdaftar"\] }

}

**POST /api/auth/login**

Login mahasiswa. Mengembalikan Sanctum token yang harus disimpan di Flutter untuk request berikutnya.

**Auth: Public**

**Request Body (JSON):**

| **Field** | **Type** | **Required** | **Keterangan**  |
| --------- | -------- | ------------ | --------------- |
| email     | string   | ✓ Ya         | Email terdaftar |
| password  | string   | ✓ Ya         | Password akun   |

**Responses:**

**200** - Login berhasil - simpan token ini di Flutter

{

"success": true,

"message": "Login berhasil",

"data": {

"token": "1|aBcDeFgHiJkLmN...",

"user": { "id": 1, "name": "Daffa", "email": "<daffa@student.telkomuniversity.ac.id>", "role": "user" }

}

}

**401** - Email atau password salah

{ "success": false, "message": "Kredensial tidak valid" }

**POST /api/auth/logout**

Logout - hapus token Sanctum yang aktif di server.

**Auth: User (Sanctum)**

**Responses:**

**200** - Logout berhasil

{ "success": true, "message": "Logout berhasil" }

**401** - Token tidak valid atau sudah expired

**GET /api/auth/me**

Ambil data profil user yang sedang login.

**Auth: User (Sanctum)**

**Responses:**

**200** - Data profil berhasil diambil

{

"success": true,

"data": {

"id": 1, "name": "Daffa", "email": "<daffa@student.telkomuniversity.ac.id>",

"role": "user", "created_at": "2026-04-01T10:00:00Z"

}

}

**401** - Token tidak valid

# **2\. Laporan Barang**

Inti dari aplikasi. Flutter bisa membuat laporan, melihat daftar, dan melihat detail. Hanya laporan berstatus verified yang tampil di daftar publik.

## **2.1 Melihat Daftar Laporan**

**GET /api/reports**

Ambil daftar laporan yang sudah diverifikasi admin (status = verified). Mendukung filter dan search.

**Auth: Public**

**Query / Path Params:**

**type** string optional - Filter: lost atau found

**search** string optional - Cari berdasarkan judul / deskripsi barang

**page** integer optional - Nomor halaman untuk pagination (default: 1)

**Responses:**

**200** - Daftar laporan berhasil diambil (terpaginasi)

{

"success": true,

"data": {

"current_page": 1,

"data": \[

{

"id": 5,

"type": "found",

"title": "Dompet hitam kulit",

"location_text": "Kantin FIF lantai 1",

"incident_date": "2026-03-28",

"status": "verified",

"image_url": "http://.../storage/reports/img1.jpg",

"reporter": { "id": 2, "name": "Farriz" },

"created_at": "2026-03-28T14:30:00Z"

}

\],

"last_page": 4,

"total": 32

}

}

**GET /api/reports/{id}**

Ambil detail satu laporan berdasarkan ID.

**Auth: Public**

**Query / Path Params:**

**id** integer required - ID laporan (path parameter)

**Responses:**

**200** - Detail laporan berhasil diambil

{

"success": true,

"data": {

"id": 5,

"type": "found",

"title": "Dompet hitam kulit",

"description": "Ditemukan di dekat kasir, ada kartu ATM di dalamnya",

"location_text": "Kantin FIF lantai 1",

"latitude": null,

"longitude": null,

"incident_date": "2026-03-28",

"status": "verified",

"images": \[

{ "id": 1, "url": "http://.../storage/reports/img1.jpg" }

\],

"reporter": { "id": 2, "name": "Farriz" },

"created_at": "2026-03-28T14:30:00Z"

}

}

**404** - Laporan tidak ditemukan

{ "success": false, "message": "Laporan tidak ditemukan" }

## **2.2 Membuat & Mengelola Laporan**

**POST /api/reports**

Buat laporan baru (hilang atau ditemukan). Status otomatis Pending setelah submit.

**Auth: User (Sanctum)**

**Request Body (JSON):**

| **Field**     | **Type** | **Required** | **Keterangan**                                                     |
| ------------- | -------- | ------------ | ------------------------------------------------------------------ |
| type          | string   | ✓ Ya         | lost atau found                                                    |
| title         | string   | ✓ Ya         | Nama / judul barang, max 255 karakter                              |
| description   | string   | ✓ Ya         | Deskripsi detail barang                                            |
| location_text | string   | ✓ Ya         | Deskripsi lokasi dalam teks                                        |
| incident_date | date     | ✓ Ya         | Tanggal kejadian, format: YYYY-MM-DD                               |
| images\[\]    | file     | Tidak        | Foto barang, boleh lebih dari 1. Format: jpg/png, max 2MB per file |
| latitude      | decimal  | Tidak        | Koordinat GPS (opsional, untuk bonus geolocation)                  |
| longitude     | decimal  | Tidak        | Koordinat GPS (opsional, untuk bonus geolocation)                  |

**Responses:**

**201** - Laporan berhasil dibuat dengan status Pending

{

"success": true,

"message": "Laporan berhasil dikirim dan menunggu verifikasi admin",

"data": { "id": 12, "title": "Kunci motor Honda", "status": "pending" }

}

**422** - Validasi gagal

{ "success": false, "errors": { "type": \["Field type wajib diisi"\] } }

**401** - Belum login

**GET /api/reports/my**

Ambil semua laporan milik user yang sedang login, termasuk semua status (pending, verified, dll).

**Auth: User (Sanctum)**

**Responses:**

**200** - Daftar laporan milik user

{

"success": true,

"data": \[

{ "id": 12, "title": "Kunci motor Honda", "type": "lost", "status": "pending", "created_at": "2026-04-01" },

{ "id": 5, "title": "Dompet hitam", "type": "found", "status": "resolved", "created_at": "2026-03-28" }

\]

}

**DELETE /api/reports/{id}**

Hapus laporan milik sendiri. Hanya bisa dilakukan oleh user yang membuat laporan tersebut.

**Auth: User (Sanctum)**

**Query / Path Params:**

**id** integer required - ID laporan (path parameter)

**Responses:**

**200** - Laporan berhasil dihapus

{ "success": true, "message": "Laporan berhasil dihapus" }

**403** - Bukan pemilik laporan

{ "success": false, "message": "Akses ditolak" }

**404** - Laporan tidak ditemukan

# **3\. Resolve Laporan**

Fitur ini memungkinkan pelapor sendiri yang menandai laporan sebagai selesai. Alurnya:

- Lost report: user lapor kehilangan → admin verifikasi → user konfirmasi barang sudah ketemu → Resolved
- Found report: user lapor nemu barang → admin verifikasi → user konfirmasi sudah dikasih ke pemilik → Resolved

Tidak ada mekanisme klaim antar user. Hanya si pelapor sendiri yang bisa resolve laporannya.

**PATCH /api/reports/{id}/resolve**

Pelapor menandai laporannya sebagai selesai. Untuk laporan lost: barang sudah ketemu. Untuk laporan found: barang sudah dikasih ke pemilik. Hanya bisa dilakukan oleh pemilik laporan dan status harus verified.

**Auth: User (Sanctum)**

**Query / Path Params:**

**id** integer required - ID laporan milik sendiri (path parameter)

**Request Body (JSON):**

| **Field** | **Type** | **Required** | **Keterangan**                                                      |
| --------- | -------- | ------------ | ------------------------------------------------------------------- |
| note      | string   | Tidak        | Catatan opsional, contoh: sudah dikembalikan langsung ke pemiliknya |

**Responses:**

**200** - Laporan berhasil di-resolve, status jadi Resolved

{

"success": true,

"message": "Laporan ditandai sebagai selesai",

"data": { "id": 5, "status": "resolved" }

}

**403** - Bukan pemilik laporan atau status belum verified

{ "success": false, "message": "Akses ditolak atau laporan belum diverifikasi" }

**404** - Laporan tidak ditemukan

# **4\. Profil Pengguna**

**GET /api/user/profile**

Ambil data profil lengkap user yang login.

**Auth: User (Sanctum)**

**Responses:**

**200** - Profil berhasil diambil

{

"success": true,

"data": {

"id": 1, "name": "Daffa Irsandy", "email": "<daffa@student.telkomuniversity.ac.id>",

"total_reports": 3, "created_at": "2026-01-15"

}

}

**PUT /api/user/profile**

Update nama atau password user.

**Auth: User (Sanctum)**

**Request Body (JSON):**

| **Field**             | **Type** | **Required** | **Keterangan**                                        |
| --------------------- | -------- | ------------ | ----------------------------------------------------- |
| name                  | string   | Tidak        | Nama baru pengguna                                    |
| current_password      | string   | Tidak        | Password lama - wajib diisi jika ingin ganti password |
| password              | string   | Tidak        | Password baru, minimal 8 karakter                     |
| password_confirmation | string   | Tidak        | Konfirmasi password baru                              |

**Responses:**

**200** - Profil berhasil diupdate

{ "success": true, "message": "Profil berhasil diupdate" }

**422** - Validasi gagal (password lama salah, dll)

# **5\. Notifikasi**

**POST /api/notifications/fcm-token**

Simpan FCM token perangkat Flutter ke server. Dipanggil setiap kali user login atau token FCM diperbarui.

**Auth: User (Sanctum)**

**Request Body (JSON):**

| **Field** | **Type** | **Required** | **Keterangan**                                  |
| --------- | -------- | ------------ | ----------------------------------------------- |
| fcm_token | string   | ✓ Ya         | Token FCM dari Firebase yang didapat di Flutter |

**Responses:**

**200** - Token berhasil disimpan

{ "success": true, "message": "FCM token berhasil disimpan" }

**GET /api/notifications**

Ambil daftar notifikasi untuk user yang login.

**Auth: User (Sanctum)**

**Responses:**

**200** - Daftar notifikasi

{

"success": true,

"data": \[

{

"id": 1,

"type": "report_verified",

"message": "Laporan 'Kunci motor Honda' kamu sudah diverifikasi",

"is_read": false,

"created_at": "2026-04-01T12:00:00Z"

}

\]

}

**PATCH /api/notifications/{id}/read**

Tandai satu notifikasi sebagai sudah dibaca.

**Auth: User (Sanctum)**

**Query / Path Params:**

**id** integer required - ID notifikasi (path parameter)

**Responses:**

**200** - Notifikasi ditandai sudah dibaca

{ "success": true, "message": "Notifikasi ditandai sudah dibaca" }

# **6\. Ringkasan Semua Endpoint**

| **Method** | **Endpoint**                 | **Auth** | **Fungsi**                                          |
| ---------- | ---------------------------- | -------- | --------------------------------------------------- |
| **POST**   | /api/auth/register           | Public   | Registrasi mahasiswa                                |
| **POST**   | /api/auth/login              | Public   | Login & dapat Sanctum token                         |
| **POST**   | /api/auth/logout             | User     | Logout & hapus token                                |
| **GET**    | /api/auth/me                 | User     | Data user yang login                                |
| **GET**    | /api/reports                 | Public   | Daftar laporan verified + filter                    |
| **GET**    | /api/reports/{id}            | Public   | Detail satu laporan                                 |
| **POST**   | /api/reports                 | User     | Buat laporan baru                                   |
| **GET**    | /api/reports/my              | User     | Laporan milik sendiri                               |
| **DELETE** | /api/reports/{id}            | User     | Hapus laporan milik sendiri                         |
| **PATCH**  | /api/reports/{id}/resolve    | User     | Tandai laporan selesai (barang ketemu/dikembalikan) |
| **GET**    | /api/user/profile            | User     | Ambil profil user                                   |
| **PUT**    | /api/user/profile            | User     | Update profil / password                            |
| **POST**   | /api/notifications/fcm-token | User     | Simpan FCM token perangkat                          |
| **GET**    | /api/notifications           | User     | Daftar notifikasi user                              |
| **PATCH**  | /api/notifications/{id}/read | User     | Tandai notifikasi sudah dibaca                      |

API Contract - Campus Lost & Found | Kelompok 1 IF-47-09 | Universitas Telkom 2026
