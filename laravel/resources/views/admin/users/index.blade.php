@extends('admin.layouts.app')

@section('title', 'User Management')

@section('content')
    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            @if ($users->count() > 0)
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="px-4 py-3">No.</th>
                                <th class="py-3">Name</th>
                                <th class="py-3">Email</th>
                                <th class="py-3">Report Count</th>
                                <th class="py-3">Status</th>
                                <th class="py-3">Registered At</th>
                                <th class="py-3 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($users as $user)
                                <tr>
                                    <td class="px-4">{{ $users->firstItem() + $loop->index }}</td>
                                    <td>{{ $user->name }}</td>
                                    <td>{{ $user->email }}</td>
                                    <td>{{ $user->reports_count }}</td>
                                    <td>
                                        <span class="badge text-bg-{{ $user->is_active ? 'success' : 'secondary' }}">
                                            {{ $user->is_active ? 'Active' : 'Inactive' }}
                                        </span>
                                    </td>
                                    <td>{{ $user->created_at?->format('d M Y H:i') ?? '-' }}</td>
                                    <td class="text-center">
                                        <div class="d-flex justify-content-center gap-2">
                                            <form action="{{ route('admin.users.toggle', $user->id) }}" method="POST">
                                                @csrf
                                                @method('PATCH')
                                                <button type="submit" class="btn btn-sm btn-outline-{{ $user->is_active ? 'warning' : 'success' }}" title="{{ $user->is_active ? 'Prevent user from logging in' : 'Allow user to log in' }}">
                                                    {{ $user->is_active ? 'Deactivate Login' : 'Activate Login' }}
                                                </button>
                                            </form>

                                            <form action="{{ route('admin.users.destroy', $user->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this user account? This action cannot be undone.');">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete user account">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <div class="p-4">
                    {{ $users->links('pagination::bootstrap-5') }}
                </div>
            @else
                <div class="p-5 text-center text-muted">
                    No registered users available.
                </div>
            @endif
        </div>
    </div>
@endsection
