@extends('admin.layouts.app')

@section('title', 'Report Details')

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

    @php
        $typeBadgeClass = $report->type === 'lost' ? 'badge-lost' : 'badge-found';
        $typeLabel = $report->type === 'lost' ? 'Lost Item' : 'Found Item';
        $statusBadgeClass = match ($report->status) {
            'verified' => 'badge-verified',
            'resolved' => 'badge-resolved',
            'rejected' => 'badge-rejected',
            'collection_pending' => 'bg-warning text-dark',
            default => 'badge-pending',
        };
        $statusLabel = match ($report->status) {
            'collection_pending' => 'Collection Pending',
            'verified' => 'Verified',
            'resolved' => 'Resolved',
            'rejected' => 'Rejected',
            'pending' => 'Pending',
            default => ucfirst($report->status),
        };
    @endphp

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
        <div class="d-flex flex-wrap gap-2">
            <span class="badge {{ $typeBadgeClass }}">{{ $typeLabel }}</span>
            <span class="badge {{ $statusBadgeClass }}">{{ $statusLabel }}</span>
        </div>

        <div class="d-flex gap-2">
            <a href="{{ route('admin.reports.index') }}" class="btn btn-outline-secondary">Back to Reports</a>
            @if ($report->status === 'pending')
                <form action="{{ route('admin.reports.verify', $report->id) }}" method="POST">
                    @csrf
                    @method('PATCH')
                    <button type="submit" class="btn btn-success">Verify</button>
                </form>

                <form
                    action="{{ route('admin.reports.reject', $report->id) }}"
                    method="POST"
                    id="rejectReportDetailForm"
                >
                    @csrf
                    @method('PATCH')
                    <input type="hidden" name="rejection_reason" id="rejectReasonDetailHidden" value="">
                    <button
                        type="button"
                        class="btn btn-outline-danger"
                        data-bs-toggle="modal"
                        data-bs-target="#rejectReportDetailModal"
                    >Reject</button>
                </form>
            @endif
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h2 class="h4 mb-3">{{ $report->title }}</h2>

                    <dl class="row mb-0">
                        <dt class="col-sm-4">Description</dt>
                        <dd class="col-sm-8">{{ $report->description }}</dd>

                        <dt class="col-sm-4">Location</dt>
                        <dd class="col-sm-8">
                            {{ $report->location_text }}
                            @if ($report->latitude && $report->longitude)
                                <div class="text-muted small mt-1">
                                    Coordinates: {{ $report->latitude }}, {{ $report->longitude }}
                                </div>
                            @endif
                        </dd>

                        <dt class="col-sm-4">Incident Date</dt>
                        <dd class="col-sm-8">{{ $report->incident_date?->format('d M Y') ?? '-' }}</dd>

                        <dt class="col-sm-4">Reported At</dt>
                        <dd class="col-sm-8">{{ $report->created_at?->format('d M Y H:i') ?? '-' }}</dd>

                        @if ($report->status === 'rejected')
                            <dt class="col-sm-4">Admin Notes</dt>
                            <dd class="col-sm-8">
                                {{ filled($report->admin_notes) ? $report->admin_notes : '-' }}
                            </dd>
                        @endif
                    </dl>
                </div>
            </div>

            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h3 class="h5 mb-3">Photo Gallery</h3>
 
                    @if ($report->reportImages->count() > 0)
                        <div class="row g-3">
                            @foreach ($report->reportImages as $image)
                                @php
                                    $imageUrl = $image->image_url;
 
                                    // Ekstrak path setelah '/storage/' agar selalu menunjuk ke storage lokal admin
                                    if (preg_match('/\/storage\/(.+)$/', $imageUrl, $matches)) {
                                        $photoSrc = asset('storage/' . $matches[1]);
                                    } elseif (\Illuminate\Support\Str::startsWith($imageUrl, ['http://', 'https://', '/storage/'])) {
                                        $photoSrc = \Illuminate\Support\Str::startsWith($imageUrl, '/storage/')
                                            ? asset(ltrim($imageUrl, '/'))
                                            : $imageUrl;
                                    } elseif (\Illuminate\Support\Str::startsWith($imageUrl, 'storage/')) {
                                        $photoSrc = asset($imageUrl);
                                    } else {
                                        $photoSrc = asset('storage/'.$imageUrl);
                                    }
                                @endphp
                                <div class="col-md-6 col-xl-4">
                                    <a href="#!" data-bs-toggle="modal" data-bs-target="#imageModal{{ $loop->iteration }}">
                                        <img
                                            src="{{ $photoSrc }}"
                                            alt="Report photo {{ $loop->iteration }}"
                                            class="img-fluid rounded border w-100"
                                            style="height: 220px; object-fit: cover; transition: transform 0.2s;"
                                            onmouseover="this.style.transform='scale(1.02)'"
                                            onmouseout="this.style.transform='scale(1)'"
                                        >
                                    </a>
                                </div>
 
                                <!-- Image Modal -->
                                <div class="modal fade" id="imageModal{{ $loop->iteration }}" tabindex="-1" aria-hidden="true">
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
                            @endforeach
                        </div>
                    @else
                        <p class="text-muted mb-0">No photos are available for this report.</p>
                    @endif
                </div>
            </div>

            <!-- Claims Submissions Section -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h3 class="h5 mb-3">Claim Submissions ({{ $report->claims->count() }})</h3>

                    @if ($report->claims->count() > 0)
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Claimant</th>
                                        <th>Proof Description</th>
                                        <th>Proof Image</th>
                                        <th>Social Media</th>
                                        <th>Status</th>
                                        <th>Code</th>
                                        <th>Submitted At</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($report->claims as $claim)
                                        <tr>
                                            <td>
                                                <strong>{{ $claim->user->name }}</strong><br>
                                                <small class="text-muted">{{ $claim->user->email }}</small>
                                            </td>
                                            <td>
                                                <span style="white-space: pre-wrap; word-break: break-word;">{{ $claim->proof_description }}</span>
                                            </td>
                                            <td>
                                                @if ($claim->proof_image_url)
                                                    @php
                                                        // Ekstrak path setelah '/storage/' agar selalu menunjuk ke storage lokal admin
                                                        if (preg_match('/\/storage\/(.+)$/', $claim->proof_image_url, $matches)) {
                                                            $proofImg = asset('storage/' . $matches[1]);
                                                        } else {
                                                            $proofImg = str_replace('http://10.0.2.2:8000', url('/'), $claim->proof_image_url);
                                                        }
                                                    @endphp
                                                    <a href="#!" data-bs-toggle="modal" data-bs-target="#claimProofModal{{ $claim->id }}">
                                                        <img src="{{ $proofImg }}" alt="Proof" class="rounded border" style="width: 50px; height: 50px; object-fit: cover; cursor: pointer; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
                                                    </a>
                                                @else
                                                    <span class="text-muted small">No photo</span>
                                                @endif
                                            </td>
                                            <td>
                                                @if ($claim->contact_social)
                                                    <span style="word-break: break-word;">{{ $claim->contact_social }}</span>
                                                @else
                                                    <span class="text-muted small">-</span>
                                                @endif
                                            </td>
                                            <td>
                                                @php
                                                    $claimBadge = match ($claim->status) {
                                                        'approved' => 'bg-success text-white',
                                                        'rejected' => 'bg-danger text-white',
                                                        'received' => 'bg-info text-dark',
                                                        default => 'bg-warning text-dark',
                                                    };
                                                @endphp
                                                <span class="badge {{ $claimBadge }}">{{ ucfirst($claim->status) }}</span>
                                            </td>
                                            <td>
                                                <code>{{ $claim->claim_code ?? '-' }}</code>
                                            </td>
                                            <td>
                                                <small class="text-muted">{{ $claim->created_at?->format('d M Y H:i') ?? '-' }}</small>
                                            </td>
                                            <td>
                                                @if ($claim->status === 'pending')
                                                     <div class="d-flex gap-1">
                                                         <button 
                                                             type="button" 
                                                             class="btn btn-sm btn-success btn-approve-claim" 
                                                             data-action="{{ route('admin.claims.approve', $claim->id) }}"
                                                             data-claimant="{{ $claim->user->name }}"
                                                             data-bs-toggle="modal"
                                                             data-bs-target="#approveClaimModal"
                                                         >Approve</button>
                                                         
                                                         <button 
                                                             type="button" 
                                                             class="btn btn-sm btn-outline-danger btn-reject-claim" 
                                                             data-action="{{ route('admin.claims.reject', $claim->id) }}"
                                                             data-claimant="{{ $claim->user->name }}"
                                                             data-bs-toggle="modal"
                                                             data-bs-target="#rejectClaimModal"
                                                         >Reject</button>
                                                     </div>
                                                @else
                                                    <span class="text-muted small">-</span>
                                                @endif
                                            </td>
                                        </tr>

                                        @if ($claim->proof_image_url)
                                            @php
                                                if (preg_match('/\/storage\/(.+)$/', $claim->proof_image_url, $matches)) {
                                                    $proofModalImg = asset('storage/' . $matches[1]);
                                                } else {
                                                    $proofModalImg = str_replace('http://10.0.2.2:8000', url('/'), $claim->proof_image_url);
                                                }
                                            @endphp
                                            <div class="modal fade" id="claimProofModal{{ $claim->id }}" tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered modal-xl">
                                                    <div class="modal-content bg-transparent border-0">
                                                        <div class="modal-header border-0 pb-0 justify-content-end p-2">
                                                            <button type="button" class="btn-close bg-white rounded-circle p-2" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body text-center p-0">
                                                            <img src="{{ $proofModalImg }}" class="img-fluid rounded shadow-lg" style="max-height: 85vh; object-fit: contain;">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endif
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <p class="text-muted mb-0">No claims have been submitted for this report.</p>
                    @endif
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h3 class="h5 mb-3">Reporter Details</h3>

                    <dl class="row mb-0">
                        <dt class="col-sm-4">Name</dt>
                        <dd class="col-sm-8">{{ $report->user?->name ?? '-' }}</dd>

                        <dt class="col-sm-4">Email</dt>
                        <dd class="col-sm-8">{{ $report->user?->email ?? '-' }}</dd>
                    </dl>
                </div>
            </div>
        </div>
    </div>

    @if ($report->status === 'pending')
        <div class="modal fade reject-modal" id="rejectReportDetailModal" tabindex="-1" aria-labelledby="rejectReportDetailModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="rejectReportDetailModalLabel">Reject Report</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="reject-copy mb-3">
                            Reject report: <strong>{{ $report->title }}</strong>?
                        </p>

                        <label for="rejectReasonDetailInput" class="form-label">Reason (optional)</label>
                        <textarea
                            id="rejectReasonDetailInput"
                            class="form-control"
                            placeholder="Enter reason for rejection..."
                        ></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="confirmRejectDetailButton">Reject</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            (() => {
                const reasonInput = document.getElementById('rejectReasonDetailInput');
                const hiddenReasonInput = document.getElementById('rejectReasonDetailHidden');
                const form = document.getElementById('rejectReportDetailForm');
                const confirmButton = document.getElementById('confirmRejectDetailButton');
                const modalElement = document.getElementById('rejectReportDetailModal');

                confirmButton?.addEventListener('click', () => {
                    if (hiddenReasonInput) {
                        hiddenReasonInput.value = reasonInput.value.trim();
                    }

                    form?.submit();
                });

                modalElement?.addEventListener('hidden.bs.modal', () => {
                    if (reasonInput) {
                        reasonInput.value = '';
                    }
                });
            })();
        </script>
    @endif

    <!-- Approve Claim Modal -->
    <div class="modal fade reject-modal" id="approveClaimModal" tabindex="-1" aria-labelledby="approveClaimModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="approveClaimModalLabel">Approve Claim</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="reject-copy mb-3 text-dark">
                        Approve item claim from <strong id="approveClaimantText"></strong>?
                    </p>
                    <div class="alert alert-warning border-0 small mb-0 rounded-3 text-dark" style="background-color: #FEF3C7; border: 1px solid #FCD34D;">
                        <strong>Important:</strong> The report status will automatically change to <strong>Collection Pending</strong> (hidden from the public feed) and all other pending claims will be automatically rejected.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form id="approveClaimForm" method="POST" action="">
                        @csrf
                        @method('PATCH')
                        <button type="submit" class="btn btn-success">Approve</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Reject Claim Modal -->
    <div class="modal fade reject-modal" id="rejectClaimModal" tabindex="-1" aria-labelledby="rejectClaimModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="rejectClaimModalLabel">Reject Claim</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="reject-copy mb-0 text-dark">
                        Reject item claim from <strong id="rejectClaimantText"></strong>?
                    </p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form id="rejectClaimForm" method="POST" action="">
                        @csrf
                        @method('PATCH')
                        <button type="submit" class="btn btn-danger">Reject</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Handler Modal Approve Claim
            const approveClaimModal = document.getElementById('approveClaimModal');
            if (approveClaimModal) {
                approveClaimModal.addEventListener('show.bs.modal', (event) => {
                    const button = event.relatedTarget;
                    const action = button.getAttribute('data-action');
                    const claimant = button.getAttribute('data-claimant');
                    
                    approveClaimModal.querySelector('#approveClaimForm').setAttribute('action', action);
                    approveClaimModal.querySelector('#approveClaimantText').textContent = claimant;
                });
            }

            // Handler Modal Reject Claim
            const rejectClaimModal = document.getElementById('rejectClaimModal');
            if (rejectClaimModal) {
                rejectClaimModal.addEventListener('show.bs.modal', (event) => {
                    const button = event.relatedTarget;
                    const action = button.getAttribute('data-action');
                    const claimant = button.getAttribute('data-claimant');
                    
                    rejectClaimModal.querySelector('#rejectClaimForm').setAttribute('action', action);
                    rejectClaimModal.querySelector('#rejectClaimantText').textContent = claimant;
                });
            }
        });
    </script>
@endsection
