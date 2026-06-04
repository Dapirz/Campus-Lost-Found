@echo off
:: Script pembantu untuk membuat tautan direktori penyimpanan (Storage Link) yang valid di Windows secara otomatis.
:: Script ini secara mandiri akan meminta hak akses Administrator (UAC Prompt) saat dijalankan.
:: Kelompok 1 — JOSSJISS (ABP 2026)

:: Langkah 1: Meminta hak akses Administrator otomatis
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Meminta hak akses Administrator...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo ==========================================================
echo [Campus Lost ^& Found] Windows Storage Link Linker
echo ==========================================================
echo.

:: Langkah 2: Menghapus tautan storage lama/rusak jika terdeteksi
if exist "%~dp0laravel\public\storage" (
    echo [1/2] Menghapus tautan penyimpanan lama yang rusak...
    rmdir "%~dp0laravel\public\storage"
) else (
    echo [1/2] Tidak ada tautan penyimpanan lama yang bertabrakan.
)

:: Langkah 3: Membuat Junction Link penyimpanan native Windows (menghindari error 403)
echo [2/2] Membuat tautan penyimpanan native Windows...
mklink /d "%~dp0laravel\public\storage" "%~dp0laravel\storage\app\public"

echo.
echo ==========================================================
echo Proses Selesai! Tautan Penyimpanan Berhasil Terhubung.
echo ==========================================================
echo.
pause
