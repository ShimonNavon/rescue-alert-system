
// const fetchWithRetry = async (url, options = {}, retries = 2, backoffMs = 1000, timeoutMs = 60000) => {
// 	const abortController = new AbortController();
// 	const timeoutId = setTimeout(() => abortController.abort(), timeoutMs);

// 	try {
// 		const response = await fetch(url, { ...options, signal: abortController.signal });
// 		if (!response.ok) {
// 			// Retry on common transient upstream errors
// 			if (retries > 0 && [502, 503, 504].includes(response.status)) {
// 				await new Promise((r) => setTimeout(r, backoffMs));
// 				return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
// 			}
// 			throw new Error(`HTTP error! Status: ${response.status}`);
// 		}
// 		return response;
// 	} catch (error) {
// 		// Avoid retrying on our own timeout aborts to prevent repeated 499s upstream
// 		if (retries > 0 && error.name !== 'AbortError' && (error.message.includes('fetch') || error.message.includes('network'))) {
// 			await new Promise((r) => setTimeout(r, backoffMs));
// 			return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
// 		}
// 		throw error;
// 	} finally {
// 		clearTimeout(timeoutId);
// 	}
// };

// export const fetchMongoData = async () => {
// 	const baseUrl = import.meta.env.VITE_API_BASE_URL ;
// 	const url = `${baseUrl}/api/data`;

// 	try {
// 		const res = await fetchWithRetry(url);

// 		// Try JSON first, fallback to text
// 		const text = await res.text();
// 		let data;
// 		try {
// 			data = text ? JSON.parse(text) : [];
// 		} catch {
// 			data = [];
// 		}

// 		return { data, error: null };
// 	} catch (error) {
// 		console.error("Error fetching data:", error);
// 		return { data: [], error: "Loading..." };
// 	}
// };
