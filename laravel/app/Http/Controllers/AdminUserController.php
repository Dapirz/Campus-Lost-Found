<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;

class AdminUserController extends Controller
{
    public function index(): View
    {
        $users = User::query()
            ->where('role', 'user')
            ->withCount('reports')
            ->latest()
            ->paginate(15);

        return view('admin.users.index', [
            'users' => $users,
        ]);
    }

    public function toggle(int $id): RedirectResponse
    {
        $user = User::query()
            ->where('role', 'user')
            ->findOrFail($id);

        $user->update([
            'is_active' => ! $user->is_active,
        ]);

        return redirect()
            ->route('admin.users.index')
            ->with('success', 'User account status updated successfully.');
    }
    public function destroy(int $id): RedirectResponse
    {
        $user = User::query()
            ->where('role', 'user')
            ->findOrFail($id);

        $user->delete();

        return redirect()
            ->route('admin.users.index')
            ->with('success', 'User account deleted successfully.');
    }
}
