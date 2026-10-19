import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import Situation from './Situation';
import { fetchUsers } from '../../services/usersService';

vi.mock('../../services/usersService', () => ({
  fetchUsers: vi.fn(),
}));

const mockedFetchUsers = vi.mocked(fetchUsers);

describe('Situation', () => {
  beforeEach(() => {
    mockedFetchUsers.mockReset();
  });

  it('renders user profiles returned by the API', async () => {
    mockedFetchUsers.mockResolvedValue({
      data: [
        {
          id: 1,
          username: 'rescuer1',
          email: 'rescuer1@example.com',
          role: 'rescuer',
          latitude: 32.0853,
          longitude: 34.7818,
        },
      ],
      error: null,
    });

    render(<Situation />);

    expect(await screen.findByText('rescuer1')).toBeInTheDocument();
    expect(
      screen
        .getAllByText('מחלץ')
        .some((node) => node.classList.contains('situation__status')),
    ).toBe(true);
    expect(
      screen.getByText('rescuer1@example.com · 32.0853, 34.7818'),
    ).toBeInTheDocument();
  });

  it('shows an error when the user request fails', async () => {
    mockedFetchUsers.mockResolvedValue({
      data: [],
      error: 'HTTP 500',
    });

    render(<Situation />);

    expect(await screen.findByText('שגיאה: HTTP 500')).toBeInTheDocument();
  });
});
