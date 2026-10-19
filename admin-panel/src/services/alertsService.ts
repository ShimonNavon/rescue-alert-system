import type {
  ApiAlert,
  ApiAlertPriority,
  ApiAlertStatus,
} from '../types/types';

const API_BASE = (import.meta.env.VITE_API_BASE_URL || '/api/').replace(/\/?$/, '/');
const TIMEOUT_MS = 60000;
const RETRY_COUNT = 2;
const BACKOFF_MS = 1000;

function getCookie(name: string): string {
  const prefix = `${name}=`;
  const match = document.cookie.split('; ').find((item) => item.startsWith(prefix));
  return match ? decodeURIComponent(match.slice(prefix.length)) : '';
}

async function errorMessage(response: Response): Promise<string> {
  try {
    const data = await response.json();
    if (typeof data?.detail === 'string') return data.detail;
    if (Array.isArray(data?.non_field_errors) && data.non_field_errors.length > 0) {
      return String(data.non_field_errors[0]);
    }
    return JSON.stringify(data);
  } catch {
    return `HTTP ${response.status}`;
  }
}

const request = async <T>(
  path: string,
  options: RequestInit = {},
  retries: number = RETRY_COUNT,
  backoffMs: number = BACKOFF_MS,
): Promise<T> => {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);
  const method = (options.method || 'GET').toUpperCase();
  const headers: HeadersInit = {
    ...(method === 'GET' || method === 'HEAD'
      ? {}
      : { 'Content-Type': 'application/json', 'X-CSRFToken': getCookie('csrftoken') }),
    ...(options.headers || {}),
  };

  try {
    const response = await fetch(`${API_BASE}${path}`, {
      credentials: 'same-origin',
      ...options,
      headers,
      signal: controller.signal,
    });

    if (!response.ok) {
      if (retries > 0 && [502, 503, 504].includes(response.status)) {
        await new Promise((resolve) => setTimeout(resolve, backoffMs));
        return request<T>(path, options, retries - 1, backoffMs * 2);
      }
      throw new Error(await errorMessage(response));
    }

    const text = await response.text();
    return (text ? JSON.parse(text) : null) as T;
  } catch (error) {
    const isAbort = (error as Error).name === 'AbortError';
    if (!isAbort && error instanceof TypeError && retries > 0) {
      await new Promise((resolve) => setTimeout(resolve, backoffMs));
      return request<T>(path, options, retries - 1, backoffMs * 2);
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
};

export const fetchAlerts = async (): Promise<{
  data: ApiAlert[];
  error: string | null;
}> => {
  try {
    const data = await request<ApiAlert[]>('alerts/');
    return { data: Array.isArray(data) ? data : [], error: null };
  } catch (error) {
    return {
      data: [],
      error: error instanceof Error ? error.message : 'Failed to fetch alerts',
    };
  }
};

export const fetchAlertById = async (
  id: number | string,
): Promise<{ data: ApiAlert | null; error: string | null }> => {
  try {
    return { data: await request<ApiAlert>(`alerts/${id}/`), error: null };
  } catch (error) {
    return {
      data: null,
      error: error instanceof Error ? error.message : 'Failed to fetch alert',
    };
  }
};

export type CreateAlertInput = {
  title: string;
  description?: string;
  latitude: number;
  longitude: number;
  priority?: ApiAlertPriority;
  status?: ApiAlertStatus;
};

export const createAlert = async (input: CreateAlertInput): Promise<ApiAlert> => {
  return request<ApiAlert>('alerts/', {
    method: 'POST',
    body: JSON.stringify(input),
  });
};
