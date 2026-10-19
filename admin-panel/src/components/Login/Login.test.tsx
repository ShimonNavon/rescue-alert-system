import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import Login from './Login';

const { loginMock } = vi.hoisted(() => ({ loginMock: vi.fn() }));

vi.mock('../../context/AuthContext', () => ({
  useAuth: () => ({
    login: loginMock,
    logout: vi.fn(),
    user: null,
    loading: false,
  }),
}));

describe('Login', () => {
  beforeEach(() => {
    loginMock.mockReset();
  });

  it('submits the entered credentials', async () => {
    loginMock.mockResolvedValue(undefined);
    render(<Login />);

    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'dispatcher@example.com' },
    });
    fireEvent.change(screen.getByPlaceholderText('••••••••'), {
      target: { value: 'strongpass123' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Sign in' }));

    await waitFor(() => {
      expect(loginMock).toHaveBeenCalledWith(
        'dispatcher@example.com',
        'strongpass123',
      );
    });
  });

  it('shows the login error returned by the API', async () => {
    loginMock.mockRejectedValue(new Error('Invalid credentials.'));
    render(<Login />);

    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'dispatcher@example.com' },
    });
    fireEvent.change(screen.getByPlaceholderText('••••••••'), {
      target: { value: 'wrong-password' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Sign in' }));

    await waitFor(() => {
      expect(screen.getByText('Invalid credentials.')).toBeInTheDocument();
    });
  });
});
