@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('content')
    <style>
        .dashboard-stat-card .card-body {
            padding: 1.2rem 1.25rem;
        }

        .dashboard-stat-label {
            margin-bottom: 0.45rem;
            color: var(--secondary);
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
        }

        .dashboard-stat-value {
            margin: 0;
            color: var(--text-dark);
            font-size: 1.85rem;
            font-weight: 800;
            line-height: 1;
        }

        .dashboard-stat-card .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 16px;
        }

        .dashboard-stat-card .stat-icon svg {
            width: 24px;
            height: 24px;
        }

        .dashboard-table-header {
            padding: 1.2rem 1.4rem;
        }

        .dashboard-table-title {
            margin: 0;
            font-size: 1.2rem;
            font-weight: 700;
            letter-spacing: -0.03em;
        }

        .dashboard-table-subtitle {
            margin: 0.2rem 0 0;
            color: var(--text-muted);
            font-size: 0.92rem;
        }
    </style>

    <div class="row g-4 mb-4">
        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Total Reports</p>
                            <h2 class="dashboard-stat-value">{{ $total_reports }}</h2>
                        </div>
                        <span class="stat-icon" style="background: var(--primary-light); color: var(--primary);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="M8 3h8l5 5v13H3V3h5Z" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M8 12h8M8 16h6" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Pending</p>
                            <h2 class="dashboard-stat-value">{{ $total_pending }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #FFF3D6; color: var(--warning);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="M8 3h8M8 21h8" stroke-width="1.8" stroke-linecap="round"/>
                                <path d="M9 3v4c0 1.4.55 2.74 1.54 3.73L12 12l1.46-1.27A5.28 5.28 0 0 0 15 7V3" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M15 21v-4c0-1.4-.55-2.74-1.54-3.73L12 12l-1.46 1.27A5.28 5.28 0 0 0 9 17v4" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Verified</p>
                            <h2 class="dashboard-stat-value">{{ $total_verified }}</h2>
                        </div>
                        <span class="stat-icon" style="background: var(--tertiary-light); color: var(--tertiary);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <circle cx="12" cy="12" r="9" stroke-width="1.8"/>
                                <path d="m8.5 12.5 2.4 2.4 4.8-5.1" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Resolved</p>
                            <h2 class="dashboard-stat-value">{{ $total_resolved }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #D1FAE5; color: #065F46;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="m12 3 7 3v5c0 4.45-3 8.42-7 9.5-4-1.08-7-5.05-7-9.5V6l7-3Z" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="m9.3 12.3 1.9 1.9 3.7-4" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Total Users</p>
                            <h2 class="dashboard-stat-value">{{ $total_users }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #FDF2E9; color: #C2410C;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="M16 20v-1a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v1" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <circle cx="9.5" cy="7" r="4" stroke-width="1.8"/>
                                <path d="M21 20v-1a4 4 0 0 0-3-3.87" stroke-width="1.8" stroke-linecap="round"/>
                                <path d="M16.5 3.3a4 4 0 0 1 0 7.4" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Lost Items</p>
                            <h2 class="dashboard-stat-value">{{ $total_lost }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #FEE2E2; color: #991B1B;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="M12 4 3 20h18L12 4Z" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M12 9v4" stroke-width="1.8" stroke-linecap="round"/>
                                <circle cx="12" cy="16.5" r="0.8" fill="currentColor" stroke="none"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Found Items</p>
                            <h2 class="dashboard-stat-value">{{ $total_found }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #D1FAE5; color: #065F46;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <path d="M14.5 5a6.5 6.5 0 1 0 4.38 11.3L22 19.4" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="m11.2 12.5 1.8 1.8 3.2-3.5" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6 col-xl-3">
            <div class="card stat-card dashboard-stat-card h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <p class="dashboard-stat-label">Rejected</p>
                            <h2 class="dashboard-stat-value">{{ $total_rejected }}</h2>
                        </div>
                        <span class="stat-icon" style="background: #FEF3F2; color: var(--danger);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <circle cx="12" cy="12" r="9" stroke-width="1.8"/>
                                <path d="m15 9-6 6m0-6 6 6" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-12">
            <div class="card h-100">
                <div class="card-header bg-white border-0 dashboard-table-header d-flex justify-content-between align-items-center">
                    <div>
                        <h3 class="dashboard-table-title">Recent Reports</h3>
                        <p class="dashboard-table-subtitle">The 5 most recent reports submitted by users.</p>
                    </div>
                    <a href="{{ route('admin.reports.index') }}" class="btn btn-sm btn-primary">View All</a>
                </div>
                <div class="card-body p-0">
                    @if ($recent_reports->count() > 0)
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th class="px-4 py-3">No.</th>
                                        <th class="px-4 py-3">Title</th>
                                        <th class="py-3">Type</th>
                                        <th class="py-3">Reporter</th>
                                        <th class="py-3">Location</th>
                                        <th class="py-3">Status</th>
                                        <th class="py-3">Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($recent_reports as $report)
                                        @php
                                            $statusBadgeClass = match ($report->status) {
                                                'verified' => 'badge-verified',
                                                'resolved' => 'badge-resolved',
                                                'rejected' => 'badge-rejected',
                                                default => 'badge-pending',
                                            };
                                            $typeBadgeClass = $report->type === 'lost' ? 'badge-lost' : 'badge-found';
                                        @endphp
                                        <tr>
                                            <td class="px-4">{{ $loop->iteration }}</td>
                                            <td class="px-4">
                                                <a href="{{ route('admin.reports.show', $report->id) }}" class="table-title-link">
                                                    {{ $report->title }}
                                                </a>
                                            </td>
                                            <td>
                                                <span class="badge {{ $typeBadgeClass }}">
                                                    {{ $report->type === 'lost' ? 'Lost' : 'Found' }}
                                                </span>
                                            </td>
                                            <td>{{ $report->user?->name ?? '-' }}</td>
                                            <td>{{ $report->location_text ?? '-' }}</td>
                                            <td>
                                                <span class="badge {{ $statusBadgeClass }}">
                                                    {{ ucfirst($report->status) }}
                                                </span>
                                            </td>
                                            <td>{{ $report->created_at?->format('d M Y') ?? '-' }}</td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="p-4 text-muted">No recent reports available.</div>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
