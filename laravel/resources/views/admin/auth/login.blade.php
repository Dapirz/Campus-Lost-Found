<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Campus Lost & Found</title>
    <link rel="icon" type="image/svg+xml" href="{{ asset('images/logo.svg') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        :root {
            --primary: #7B5B4A;
            --secondary: #A38E78;
            --tertiary: #5E7654;
            --neutral: #FAF2EB;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            background: var(--neutral);
        }

        .login-shell {
            min-height: 100vh;
            display: flex;
        }

        .login-hero {
            flex: 0 0 60%;
            position: relative;
            background-image:
                linear-gradient(135deg, rgba(123, 91, 74, 0.85) 0%, rgba(94, 118, 84, 0.85) 100%),
                url('/images/login-bg.jpg');
            background-size: cover;
            background-position: center;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 48px;
        }

        .login-brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            font-weight: 800;
            font-size: 1.15rem;
            letter-spacing: -0.02em;
        }

        .brand-icon {
            width: 64px;
            height: 64px;
            display: block;
            flex-shrink: 0;
            object-fit: contain;
        }

        .hero-content {
            max-width: 560px;
            margin-bottom: 8vh;
        }

        .hero-content h1 {
            font-size: clamp(2.6rem, 4vw, 4.25rem);
            font-weight: 800;
            letter-spacing: -0.04em;
            line-height: 1.05;
            margin-bottom: 1.25rem;
        }

        .hero-content p {
            max-width: 500px;
            color: rgba(255, 255, 255, 0.7);
            font-size: 1.05rem;
            line-height: 1.75;
            margin: 0;
        }

        .hero-footer {
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.875rem;
        }

        .login-panel {
            flex: 0 0 40%;
            background: var(--neutral);
            display: flex;
            align-items: center;
            padding: 48px;
        }

        .login-panel-inner {
            width: 100%;
            max-width: 430px;
            margin: 0 auto;
        }

        .login-heading {
            font-size: 2rem;
            font-weight: 800;
            color: #101828;
            margin-bottom: 0.5rem;
            letter-spacing: -0.03em;
        }

        .login-subtext {
            color: var(--secondary);
            margin-bottom: 2rem;
        }

        .form-label {
            font-weight: 600;
            color: #344054;
            margin-bottom: 0.5rem;
        }

        .input-shell {
            position: relative;
        }

        .input-icon,
        .password-toggle {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #667085;
        }

        .input-icon {
            left: 14px;
        }

        .password-toggle {
            right: 14px;
            background: transparent;
            border: 0;
            padding: 0;
            cursor: pointer;
        }

        .form-control {
            height: 52px;
            border: 1px solid #D0D5DD;
            border-radius: 8px;
            padding-left: 44px;
            padding-right: 44px;
            background: #FFFFFF;
        }

        .form-control::placeholder {
            color: #98A2B3;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 82, 204, 0.1);
        }

        .btn-signin {
            width: 100%;
            height: 52px;
            border: 0;
            border-radius: 8px;
            background: var(--primary);
            color: #fff;
            font-weight: 700;
        }

        .btn-signin:hover {
            background: #003D99;
        }

        .login-note {
            margin-top: 1.25rem;
            color: #98A2B3;
            font-size: 0.875rem;
            text-align: center;
        }

        .alert {
            border-radius: 10px;
            border: 0;
        }

        @media (max-width: 767.98px) {
            .login-hero {
                display: none;
            }

            .login-panel {
                flex: 1 1 100%;
                padding: 32px 24px;
            }
        }
    </style>
</head>

<body>
    <div class="login-shell">
        <section class="login-hero">
            <div class="login-brand">
                <img class="brand-icon" src="{{ asset('images/logo.png') }}" alt="Campus Lost &amp; Found logo">
                <span>Lost &amp; Found</span>
            </div>

            <div class="hero-content">
                <h1>Campus Lost &amp; Found.</h1>
                <p>
                    A centralized platform to report and recover lost items across the campus environment.
                </p>
            </div>
        </section>

        <section class="login-panel">
            <div class="login-panel-inner">
                <h1 class="login-heading">Welcome back</h1>
                <p class="login-subtext">Sign in to access the admin dashboard.</p>

                @if (session('error'))
                    <div class="alert alert-danger" role="alert">
                        {{ session('error') }}
                    </div>
                @endif

                @if ($errors->any())
                    <div class="alert alert-danger" role="alert">
                        The login details are not valid. Please review and try again.
                    </div>
                @endif

                @if (session('success'))
                    <div class="alert alert-success" role="alert">
                        {{ session('success') }}
                    </div>
                @endif

                <form action="{{ route('admin.login.submit') }}" method="POST">
                    @csrf

                    <div class="mb-3">
                        <label for="email" class="form-label">Email Address</label>
                        <div class="input-shell">
                            <span class="input-icon">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                                    <path d="M4 6h16v12H4z" stroke-width="1.8" stroke-linejoin="round" />
                                    <path d="m4 7 8 6 8-6" stroke-width="1.8" stroke-linecap="round"
                                        stroke-linejoin="round" />
                                </svg>
                            </span>
                            <input type="email" class="form-control @error('email') is-invalid @enderror" id="email"
                                name="email" value="{{ old('email') }}" placeholder="admin@campuslostfound.com" required
                                autofocus>
                        </div>
                        @error('email')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label">Password</label>
                        <div class="input-shell">
                            <span class="input-icon">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                                    <rect x="5" y="11" width="14" height="10" rx="2" stroke-width="1.8" />
                                    <path d="M8 11V8a4 4 0 1 1 8 0v3" stroke-width="1.8" stroke-linecap="round" />
                                </svg>
                            </span>
                            <input type="password" class="form-control @error('password') is-invalid @enderror"
                                id="password" name="password" placeholder="Enter your password" required>
                            <button type="button" class="password-toggle" id="togglePassword"
                                aria-label="Toggle password">
                                <svg id="eyeOpen" width="18" height="18" viewBox="0 0 24 24" fill="none"
                                    stroke="currentColor">
                                    <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12Z" stroke-width="1.8"
                                        stroke-linecap="round" stroke-linejoin="round" />
                                    <circle cx="12" cy="12" r="3" stroke-width="1.8" />
                                </svg>
                            </button>
                        </div>
                        @error('password')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <button type="submit" class="btn-signin">Sign In</button>
                </form>
            </div>
        </section>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
    <script>
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');
        const eyeOpen = document.getElementById('eyeOpen');

        togglePassword?.addEventListener('click', function () {
            const isPassword = passwordInput.type === 'password';
            passwordInput.type = isPassword ? 'text' : 'password';
            eyeOpen.innerHTML = isPassword
                ? '<path d="M3 3 21 21" stroke-width="1.8" stroke-linecap="round"/><path d="M10.6 10.7a3 3 0 0 0 4.2 4.2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M9.9 5.1A10.9 10.9 0 0 1 12 5c7 0 11 7 11 7a20.1 20.1 0 0 1-4.2 4.8" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M6.6 6.7C3.9 8.5 2 12 2 12s4 7 10 7c1.8 0 3.4-.4 4.8-1.2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
                : '<path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12Z" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke-width="1.8"/>';
        });
    </script>
</body>

</html>