<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Campus Lost & Found</title>
    <link rel="icon" type="image/svg+xml" href="{{ asset('images/logo.svg') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        :root {
            --primary: #7B5B4A;
            --primary-dark: #5E4336;
            --primary-light: #E8DDD7;
            --secondary: #A38E78;
            --tertiary: #5E7654;
            --tertiary-light: #E9EEE7;
            --neutral: #FAF2EB;
            --neutral-dark: #E6DCD3;
            --text-dark: #30231D;
            --text-muted: #8A7E71;
            --success: #5E7654;
            --warning: #D98C3A;
            --danger: #C43A3A;
            --white: #FFFFFF;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--neutral);
            color: var(--text-dark);
        }

        .admin-shell {
            min-height: 100vh;
        }

        .admin-navbar {
            background: var(--white);
            border-bottom: 1px solid var(--neutral-dark);
            box-shadow: 0 1px 2px rgba(16, 24, 40, 0.04);
        }

        .admin-navbar .navbar-brand {
            display: inline-flex;
            align-items: center;
            gap: 0.9rem;
            margin-right: 2rem;
        }

        .brand-logo {
            width: 36px;
            height: 36px;
            display: block;
            flex-shrink: 0;
            object-fit: contain;
        }

        .brand-text {
            line-height: 1.15;
        }

        .brand-text strong {
            display: block;
            font-size: 1rem;
            font-weight: 800;
            color: var(--text-dark);
            letter-spacing: -0.02em;
        }

        .brand-text span {
            display: block;
            font-size: 0.82rem;
            color: var(--text-muted);
        }

        .navbar-nav.admin-nav {
            gap: 0.35rem;
        }

        .admin-nav .nav-link {
            color: var(--secondary);
            border-radius: 999px;
            padding: 0.7rem 1rem;
            display: inline-flex;
            align-items: center;
            gap: 0.65rem;
            font-weight: 600;
            transition: background-color 0.2s ease, color 0.2s ease, box-shadow 0.2s ease;
        }

        .admin-nav .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
        }

        .admin-nav .nav-link.active {
            background: var(--primary-light);
            color: var(--primary);
            box-shadow: inset 0 0 0 1px rgba(123, 91, 74, 0.15);
        }

        .menu-icon {
            width: 18px;
            height: 18px;
            flex-shrink: 0;
        }

        .navbar-toggler {
            border-color: var(--neutral-dark);
            border-radius: 10px;
            padding: 0.5rem 0.65rem;
        }

        .navbar-toggler:focus {
            box-shadow: 0 0 0 3px rgba(123, 91, 74, 0.15);
        }

        .admin-user-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.55rem 0.9rem;
            border-radius: 999px;
            background: var(--neutral);
            color: var(--text-dark);
            font-weight: 600;
        }

        .admin-user-avatar {
            width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: var(--white);
            color: var(--primary);
            border: 1px solid var(--neutral-dark);
        }

        .btn-logout {
            border: 1px solid var(--danger);
            color: var(--danger);
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-logout:hover {
            background: var(--danger);
            color: var(--white);
        }

        .admin-main {
            padding: 2rem 0;
        }

        .page-heading {
            margin-bottom: 1.5rem;
        }

        .page-heading h1 {
            margin: 0;
            font-size: 1.75rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: var(--text-dark);
        }

        .page-heading p {
            margin: 0.45rem 0 0;
            color: var(--text-muted);
        }

        .card {
            border: 1px solid var(--neutral-dark);
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }

        .stat-card {
            background: var(--white);
            transition: box-shadow 0.2s ease, transform 0.2s ease;
        }

        .stat-card:hover {
            box-shadow: 0 10px 25px rgba(16, 24, 40, 0.08);
            transform: translateY(-2px);
        }

        .stat-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .table {
            margin-bottom: 0;
        }

        .table thead th {
            background: var(--neutral);
            color: var(--secondary);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            border-bottom: 1px solid var(--neutral-dark);
            border-top: 0;
            white-space: nowrap;
        }

        .table tbody tr:hover {
            background: #FAF5F0;
        }

        .table tbody td {
            border-color: var(--neutral-dark);
            color: var(--text-dark);
        }

        .table-title-link {
            color: var(--primary);
            font-weight: 500;
            text-decoration: none;
        }

        .table-title-link:hover {
            color: var(--primary-dark);
        }

        .form-control,
        .form-select {
            border: 1px solid var(--neutral-dark);
            border-radius: 8px;
            background: var(--white);
        }

        .form-control:focus,
        .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(123, 91, 74, 0.15);
        }

        .btn-primary {
            background: var(--primary);
            border-color: var(--primary);
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-primary:hover,
        .btn-primary:focus {
            background: var(--primary-dark);
            border-color: var(--primary-dark);
        }

        .badge {
            border-radius: 999px;
            font-weight: 600;
            padding: 0.45rem 0.7rem;
        }

        .badge-pending {
            background: #FEF3C7;
            color: #92400E;
        }

        .badge-verified {
            background: var(--tertiary-light);
            color: var(--tertiary);
        }

        .badge-resolved {
            background: #D1FAE5;
            color: #065F46;
        }

        .badge-rejected {
            background: #FEE2E2;
            color: #991B1B;
        }

        .badge-lost {
            background: #FEE2E2;
            color: #991B1B;
        }

        .badge-found {
            background: #D1FAE5;
            color: #065F46;
        }

        .icon-action-btn {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid transparent;
            text-decoration: none;
            font-size: 14px;
            line-height: 1;
        }

        .icon-action-btn.approve {
            background: var(--tertiary);
            color: var(--white);
        }

        .icon-action-btn.reject {
            background: var(--danger);
            color: var(--white);
        }

        .icon-action-btn.edit {
            background: transparent;
            border-color: var(--secondary);
            color: var(--secondary);
        }

        .icon-action-btn.delete {
            background: transparent;
            border-color: var(--danger);
            color: var(--danger);
        }

        .icon-action-btn:hover {
            opacity: 0.92;
        }

        .alert-success {
            background: var(--tertiary-light);
            border-color: rgba(11, 122, 117, 0.15);
            color: var(--tertiary);
        }

        .alert-danger {
            background: #FEF3F2;
            border-color: rgba(240, 68, 56, 0.15);
            color: #B42318;
        }

        @media (max-width: 991.98px) {
            .admin-main {
                padding: 1.5rem 0;
            }

            .admin-user-chip {
                display: none;
            }

            .navbar-collapse {
                padding-top: 1rem;
            }

            .admin-nav .nav-link {
                width: 100%;
                border-radius: 12px;
            }

            .navbar-actions {
                margin-top: 1rem;
                padding-top: 1rem;
                border-top: 1px solid var(--neutral-dark);
                align-items: flex-start !important;
            }
        }

        /* Pagination Override to Earth-Tones */
        .pagination .page-item.active .page-link {
            background-color: var(--primary);
            border-color: var(--primary);
            color: var(--white);
        }

        .pagination .page-link {
            color: var(--primary);
            border-color: var(--neutral-dark);
            background-color: var(--white);
        }

        .pagination .page-link:hover {
            background-color: var(--primary-light);
            border-color: var(--neutral-dark);
            color: var(--primary-dark);
        }

        .pagination .page-item.disabled .page-link {
            background-color: var(--neutral);
            border-color: var(--neutral-dark);
            color: var(--text-muted);
        }
    </style>
</head>

<body>
    <div class="admin-shell">
        <nav class="navbar navbar-expand-lg admin-navbar">
            <div class="container-fluid px-4">
                <a class="navbar-brand" href="{{ route('admin.dashboard') }}">
                    <img class="brand-logo" src="{{ asset('images/logo.png') }}" alt="Campus Lost &amp; Found logo">
                    <span class="brand-text">
                        <strong>Lost &amp; Found</strong>
                        <span>Campus Admin Panel</span>
                    </span>
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar"
                    aria-controls="adminNavbar" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="adminNavbar">
                    <ul class="navbar-nav admin-nav me-auto">
                        <li class="nav-item">
                            <a href="{{ route('admin.dashboard') }}"
                                class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" class="menu-icon">
                                    <path d="M4 13h7V4H4v9Zm9 7h7V4h-7v16ZM4 20h7v-5H4v5Z" stroke="currentColor"
                                        stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
                                </svg>
                                <span>Dashboard</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="{{ route('admin.reports.index') }}"
                                class="nav-link {{ request()->routeIs('admin.reports.*') ? 'active' : '' }}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" class="menu-icon">
                                    <path d="M8 3h8l5 5v13H3V3h5Z" stroke="currentColor" stroke-width="1.8"
                                        stroke-linecap="round" stroke-linejoin="round" />
                                    <path d="M8 12h8M8 16h5" stroke="currentColor" stroke-width="1.8"
                                        stroke-linecap="round" />
                                </svg>
                                <span>Reports</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="{{ route('admin.users.index') }}"
                                class="nav-link {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" class="menu-icon">
                                    <path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" stroke="currentColor"
                                        stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
                                    <circle cx="9.5" cy="7" r="4" stroke="currentColor" stroke-width="1.8" />
                                    <path d="M17 8a4 4 0 0 1 0 8m2.5-8a4 4 0 0 1 0 8" stroke="currentColor"
                                        stroke-width="1.8" stroke-linecap="round" />
                                </svg>
                                <span>Users</span>
                            </a>
                        </li>
                    </ul>

                    <div class="d-flex align-items-center gap-3 navbar-actions">
                        <span class="admin-user-chip">
                            <span class="admin-user-avatar">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" class="menu-icon">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke-width="1.8"
                                        stroke-linecap="round" stroke-linejoin="round" />
                                    <circle cx="12" cy="7" r="4" stroke-width="1.8" />
                                </svg>
                            </span>
                            <span>{{ auth()->user()->name }}</span>
                        </span>

                        <form action="{{ route('admin.logout') }}" method="POST" class="mb-0">
                            @csrf
                            <button type="submit" class="btn btn-sm btn-logout">Logout</button>
                        </form>
                    </div>
                </div>
            </div>
        </nav>

        <main class="admin-main">
            <div class="container-fluid px-4">
                <div class="page-heading">
                    <h1>@yield('title', 'Admin Panel')</h1>
                    <p>Monitor reports and users across the campus admin dashboard.</p>
                </div>

                @if (session('success'))
                    <div class="alert alert-success" role="alert">
                        {{ session('success') }}
                    </div>
                @endif

                @if (session('error'))
                    <div class="alert alert-danger" role="alert">
                        {{ session('error') }}
                    </div>
                @endif

                @yield('content')
            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>

</html>
