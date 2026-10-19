import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import EventTable from './EventTable';
import { fetchAlerts } from '../../services/alertsService';

vi.mock('../../services/alertsService', () => ({
  fetchAlerts: vi.fn(),
}));

const mockedFetchAlerts = vi.mocked(fetchAlerts);

describe('EventTable', () => {
  beforeEach(() => {
    mockedFetchAlerts.mockReset();
  });

  it('renders alerts returned by the API', async () => {
    mockedFetchAlerts.mockResolvedValue({
      data: [
        {
          id: 1,
          title: 'Building Fire',
          description: 'Multiple floors affected',
          latitude: 32.0853,
          longitude: 34.7818,
          status: 'OPEN',
          priority: 'HIGH',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      ],
      error: null,
    });

    render(<EventTable />);

    expect(await screen.findByText('Building Fire')).toBeInTheDocument();
    expect(
      screen.getAllByText('פתוח').some((node) => node.classList.contains('status')),
    ).toBe(true);
    expect(
      screen.getAllByText('גבוה').some((node) => node.classList.contains('priority')),
    ).toBe(true);
    expect(screen.getByText('32.0853, 34.7818')).toBeInTheDocument();
  });

  it('shows an error when the alert request fails', async () => {
    mockedFetchAlerts.mockResolvedValue({
      data: [],
      error: 'HTTP 500',
    });

    render(<EventTable />);

    expect(await screen.findByText('שגיאה: HTTP 500')).toBeInTheDocument();
  });
});
