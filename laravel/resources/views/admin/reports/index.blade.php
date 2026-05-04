@extends('admin.layouts.app')

@section('title', 'Report Management')

@section('content')
    <style>
        .reject-modal .modal-content {
            border: 0;
            border-radius: 16px;
            overflow: hidden;
        }

        .reject-modal .modal-header,
        .reject-modal .modal-footer {
            padding: 1.35rem 1.5rem;
        }

        .reject-modal .modal-body {
            padding: 1.25rem 1.5rem 1.5rem;
        }

        .reject-modal .modal-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        .reject-modal .btn-close {
            opacity: 0.7;
        }

        .reject-modal .btn-close:focus {
            box-shadow: none;
        }

        .reject-copy {
            margin-bottom: 1.15rem;
            color: var(--text-dark);
            font-size: 1rem;
        }

        .reject-copy strong {
            font-weight: 700;
        }

        .reject-modal textarea.form-control {
            min-height: 120px;
            resize: vertical;
            padding: 0.9rem 1rem;
        }
    </style>

    <div class="card mb-4">
        <div class="card-body p-4">
            <form action="{{ route('admin.reports.index') }}" method="GET" class="row g-3">
                <div class="col-md-3">
                    <label for="search" class="form-label">Search</label>
                    <input
                        type="text"
                        name="search"
                        id="search"
                        class="form-control"
                        placeholder="Search item title..."
                        value="{{ request('search') }}"
                    >
                </div>

                <div class="col-md-3">
                    <label for="type" class="form-label">Type</label>
                    <select name="type" id="type" class="form-select">
                        <option value="">All Types</option>
                        <option value="lost" @selected(request('type') === 'lost')>Lost Item</option>
                        <option value="found" @selected(request('type') === 'found')>Found Item</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label for="status" class="form-label">Status</label>
                    <select name="status" id="status" class="form-select">
                        <option value="">All Statuses</option>
                        <option value="pending" @selected(request('status') === 'pending')>Pending</option>
                        <option value="verified" @selected(request('status') === 'verified')>Verified</option>
                        <option value="resolved" @selected(request('status') === 'resolved')>Resolved</option>
                        <option value="rejected" @selected(request('status') === 'rejected')>Rejected</option>
                    </select>
                </div>

                <div class="col-12 d-flex gap-2">
                    <button type="submit" class="btn btn-primary">Filter</button>
                    <a href="{{ route('admin.reports.index') }}" class="btn btn-outline-secondary">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-body p-0">
            @if ($reports->count() > 0)
                <div class="table-responsive">
                    <table class="table align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="px-4 py-3">No.</th>
                                <th class="py-3">Photo</th>
                                <th class="py-3">Item Title</th>
                                <th class="py-3">Type</th>
                                <th class="py-3">Reporter</th>
                                <th class="py-3">Status</th>
                                <th class="py-3">Reported At</th>
                                <th class="py-3 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($reports as $report)
                                @php
                                    $imageUrl = $report->image_url;
                                    $photoSrc = null;

                                    if ($imageUrl) {
                                        // Fix for emulator URLs so images show correctly in web admin
                                        $imageUrl = str_replace('http://10.0.2.2:8000', url('/'), $imageUrl);
                                        
                                        if (\Illuminate\Support\Str::startsWith($imageUrl, ['http://', 'https://', '/storage/'])) {
                                            $photoSrc = \Illuminate\Support\Str::startsWith($imageUrl, '/storage/')
                                                ? asset(ltrim($imageUrl, '/'))
                                                : $imageUrl;
                                        } elseif (\Illuminate\Support\Str::startsWith($imageUrl, 'storage/')) {
                                            $photoSrc = asset($imageUrl);
                                        } else {
                                            $photoSrc = asset('storage/'.$imageUrl);
                                        }
                                    }

                                    $typeBadgeClass = $report->type === 'lost' ? 'badge-lost' : 'badge-found';
                                    $typeLabel = $report->type === 'lost' ? 'Lost' : 'Found';
                                    $statusBadgeClass = match ($report->status) {
                                        'verified' => 'badge-verified',
                                        'resolved' => 'badge-resolved',
                                        'rejected' => 'badge-rejected',
                                        default => 'badge-pending',
                                    };
                                @endphp
                                <tr>
                                    <td class="px-4">{{ $reports->firstItem() + $loop->index }}</td>
                                    <td>
                                        @if ($photoSrc)
                                            <a href="#!" data-bs-toggle="modal" data-bs-target="#indexImageModal{{ $report->id }}">
                                                <img
                                                    src="{{ $photoSrc }}"
                                                    alt="{{ $report->title }}"
                                                    class="rounded object-fit-cover shadow-sm"
                                                    style="width: 56px; height: 56px; transition: transform 0.2s;"
                                                    onmouseover="this.style.transform='scale(1.05)'"
                                                    onmouseout="this.style.transform='scale(1)'"
                                                >
                                            </a>

                                            <!-- Image Modal -->
                                            <div class="modal fade" id="indexImageModal{{ $report->id }}" tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered modal-xl">
                                                    <div class="modal-content bg-transparent border-0">
                                                        <div class="modal-header border-0 pb-0 justify-content-end p-2">
                                                            <button type="button" class="btn-close bg-white rounded-circle p-2" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body text-center p-0">
                                                            <img src="{{ $photoSrc }}" class="img-fluid rounded shadow-lg" style="max-height: 85vh; object-fit: contain;">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @else
                                            <div
                                                class="d-flex align-items-center justify-content-center bg-light text-muted rounded"
                                                style="width: 56px; height: 56px;"
                                            >
                                                N/A
                                            </div>
                                        @endif
                                    </td>
                                    <td>
                                        <a href="{{ route('admin.reports.show', $report->id) }}" class="table-title-link">
                                            {{ $report->title }}
                                        </a>
                                    </td>
                                    <td>
                                        <span class="badge {{ $typeBadgeClass }}">{{ $typeLabel }}</span>
                                    </td>
                                    <td>{{ $report->user?->name ?? '-' }}</td>
                                    <td>
                                        <span class="badge {{ $statusBadgeClass }}">{{ ucfirst($report->status) }}</span>
                                    </td>
                                    <td>{{ $report->created_at?->format('d M Y H:i') ?? '-' }}</td>
                                    <td class="text-center">
                                        <div class="d-flex justify-content-center gap-2">
                                            @if ($report->status === 'pending')
                                                <form action="{{ route('admin.reports.verify', $report->id) }}" method="POST">
                                                    @csrf
                                                    @method('PATCH')
                                                    <button type="submit" class="icon-action-btn approve" title="Verify">&#10003;</button>
                                                </form>

                                                <form
                                                    action="{{ route('admin.reports.reject', $report->id) }}"
                                                    method="POST"
                                                    class="js-reject-report-form"
                                                    data-report-title="{{ e($report->title) }}"
                                                >
                                                    @csrf
                                                    @method('PATCH')
                                                    <input type="hidden" name="rejection_reason" value="">
                                                    <button
                                                        type="button"
                                                        class="icon-action-btn reject js-open-reject-modal"
                                                        title="Reject"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#rejectReportModal"
                                                        data-report-title="{{ e($report->title) }}"
                                                    >&#10005;</button>
                                                </form>
                                            @endif
                                            <form
                                                action="{{ route('admin.reports.destroy', $report->id) }}"
                                                method="POST"
                                                onsubmit="return confirm('Are you sure you want to delete this report?');"
                                            >
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="icon-action-btn delete" title="Delete">&#128465;</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <div class="p-4">
                    {{ $reports->links('pagination::bootstrap-5') }}
                </div>
            @else
                <div class="p-5 text-center text-muted">
                    No reports matched the current filters.
                </div>
            @endif
        </div>
    </div>

    <div class="modal fade reject-modal" id="rejectReportModal" tabindex="-1" aria-labelledby="rejectReportModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="rejectReportModalLabel">Reject Report</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="reject-copy mb-3">
                        Reject report: <strong id="rejectReportTitle">-</strong>?
                    </p>

                    <label for="rejectReasonInput" class="form-label">Reason (optional)</label>
                    <textarea
                        id="rejectReasonInput"
                        class="form-control"
                        placeholder="Enter reason for rejection..."
                    ></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmRejectReportButton">Reject</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        (() => {
            const modalElement = document.getElementById('rejectReportModal');
            const titleElement = document.getElementById('rejectReportTitle');
            const reasonInput = document.getElementById('rejectReasonInput');
            const confirmButton = document.getElementById('confirmRejectReportButton');
            let activeForm = null;

            document.querySelectorAll('.js-open-reject-modal').forEach((button) => {
                button.addEventListener('click', () => {
                    activeForm = button.closest('.js-reject-report-form');
                    titleElement.textContent = button.dataset.reportTitle || '-';
                    reasonInput.value = '';
                });
            });

            confirmButton?.addEventListener('click', () => {
                if (!activeForm) {
                    return;
                }

                const hiddenReasonInput = activeForm.querySelector('input[name="rejection_reason"]');

                if (hiddenReasonInput) {
                    hiddenReasonInput.value = reasonInput.value.trim();
                }

                activeForm.submit();
            });

            modalElement?.addEventListener('hidden.bs.modal', () => {
                activeForm = null;
                titleElement.textContent = '-';
                reasonInput.value = '';
            });
        })();
    </script>
@endsection
