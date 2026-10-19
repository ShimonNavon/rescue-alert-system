import type { ApiUserProfile } from '../types/types';

const API_BASE = (import.meta.env.VITE_API_BASE_URL || '/api/').replace(/\/?$/, '/');

export const fetchUsers = async (): Promise<{
  data: ApiUserProfile[];
  error: string | null;
}> => {
  try {
    const response = await fetch(`${API_BASE}user/`, {
      credentials: 'same-origin',
    });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    const data = await response.json();
    return { data: Array.isArray(data) ? data : [], error: null };
  } catch (error) {
    return {
      data: [],
      error: error instanceof Error ? error.message : 'Failed to fetch users',
    };
  }
};
