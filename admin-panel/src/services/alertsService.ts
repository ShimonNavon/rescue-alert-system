import {type  Alert } from '../types/types';

const TIMEOUT_MS = 60000;
const RETRY_COUNT = 2;
const BACKOFF_MS = 1000;

/**
 * Fetch alerts with retry logic and timeout handling
 */
const fetchWithRetry = async (
  url: string,
  options: RequestInit = {},
  retries: number = RETRY_COUNT,
  backoffMs: number = BACKOFF_MS,
  timeoutMs: number = TIMEOUT_MS
): Promise<Response> => {
  const abortController = new AbortController();
  const timeoutId = setTimeout(() => abortController.abort(), timeoutMs);

  try {
    const response = await fetch(url, { ...options, signal: abortController.signal });
    if (!response.ok) {
      // Retry on common transient upstream errors
      if (retries > 0 && [502, 503, 504].includes(response.status)) {
        await new Promise((r) => setTimeout(r, backoffMs));
        return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
      }
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    return response;
  } catch (error) {
    // Avoid retrying on our own timeout aborts
    if (retries > 0 && (error as Error).name !== 'AbortError' && ((error as Error).message.includes('fetch') || (error as Error).message.includes('network'))) {
      await new Promise((r) => setTimeout(r, backoffMs));
      return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
};

/**
 * Fetch all alerts from the API
 * @returns Array of alert objects and error information
 */
export const fetchAlerts = async (): Promise<{ data: Alert[]; error: string | null }> => {
  const baseUrl = import.meta.env.VITE_API_BASE_URL;
  const url = `${baseUrl}alerts/`;

  try {
    const res = await fetchWithRetry(url);

    // Try JSON first, fallback to empty array
    const text = await res.text();
    let data: Alert[] = [];
    try {
      const parsed = text ? JSON.parse(text) : [];
      data = Array.isArray(parsed) ? parsed : [parsed];
    } catch {
      console.error('Failed to parse alerts response as JSON');
      data = [];
    }

    return { data, error: null };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Failed to fetch alerts';
    console.error('Error fetching alerts:', errorMessage);
    return { data: [], error: errorMessage };
  }
};

/**
 * Fetch alerts with optional filtering
 * @param filter - Optional query parameters for filtering (e.g., { severity: 'high', type: 'error' })
 * @returns Array of alert objects and error information
 */
export const fetchAlertsWithFilter = async (
  filter?: Record<string, string | number | boolean>
): Promise<{ data: Alert[]; error: string | null }> => {
  const baseUrl = import.meta.env.VITE_API_BASE_URL;
  let url = `${baseUrl}alerts/`;

  if (filter) {
    const params = new URLSearchParams();
    Object.entries(filter).forEach(([key, value]) => {
      params.append(key, String(value));
    });
    url += `?${params.toString()}`;
  }

  try {
    const res = await fetchWithRetry(url);

    const text = await res.text();
    let data: Alert[] = [];
    try {
      const parsed = text ? JSON.parse(text) : [];
      data = Array.isArray(parsed) ? parsed : [parsed];
    } catch {
      console.error('Failed to parse alerts response as JSON');
      data = [];
    }

    return { data, error: null };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Failed to fetch alerts';
    console.error('Error fetching alerts:', errorMessage);
    return { data: [], error: errorMessage };
  }
};


export const fetchAlertById = async (
  id: number | string
): Promise<{ data: Alert | null; error: string | null }> => {
  try {
    const baseUrl = import.meta.env.VITE_API_BASE_URL;
    const url = `${baseUrl.replace(/\/$/, "")}/alerts/${id}/`;

    const res = await fetchWithRetry(url);
    const text = await res.text();

    const data = text ? JSON.parse(text) : null;

    return { data, error: null };
  } catch (error) {
    return {
      data: null,
      error: error instanceof Error ? error.message : "Failed to fetch alert",
    };
  }
};