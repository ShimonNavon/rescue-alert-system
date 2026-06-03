// import {fetchWithRetry} from "./fetchData"

// // const fetchWithRetry = async (url, options = {}, retries = 0, backoffMs = 1000, timeoutMs = 60000) => {
// // 	// For POST, default to no retries to avoid duplicate submissions.
// // 	const abortController = new AbortController();
// // 	const timeoutId = setTimeout(() => abortController.abort(), timeoutMs);

// // 	try {
// // 		const response = await fetch(url, { ...options, signal: abortController.signal });
// // 		if (!response.ok) {
// // 			if (retries > 0 && [502, 503, 504].includes(response.status)) {
// // 				await new Promise((r) => setTimeout(r, backoffMs));
// // 				return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
// // 			}
// // 			throw new Error(`HTTP error! Status: ${response.status}`);
// // 		}
// // 		return response;
// // 	} catch (error) {
// // 		// Do not retry on AbortError to avoid upstream 499s; allow a longer timeout instead.
// // 		if (retries > 0 && error.name !== 'AbortError' && (error.message.includes('fetch') || error.message.includes('network'))) {
// // 			await new Promise((r) => setTimeout(r, backoffMs));
// // 			return fetchWithRetry(url, options, retries - 1, backoffMs * 2, timeoutMs);
// // 		}
// // 		throw error;
// // 	} finally {
// // 		clearTimeout(timeoutId);
// // 	}
// // };

// export const handleSubmit = async (string1, string2, string3, string4) => {
// 	const baseUrl = import.meta.env.VITE_API_BASE_URL ;
// 	const url = `${baseUrl}/api/data`;

// 	try {
// 		const res = await fetchWithRetry(url, {
// 			method: "POST",
// 			headers: {
// 				"Content-Type": "application/json",
// 				"X-Idempotency-Key": `${Date.now()}-${Math.random().toString(36).slice(2)}`
// 			},
// 			// keepalive helps the browser try to complete the request even if the page is navigating
// 			keepalive: true,
// 			body: JSON.stringify({ string1, string2, string3, string4 })
// 		});

// 		const text = await res.text();
// 		let data;
// 		try {
// 			data = text ? JSON.parse(text) : { message: "No response from server" };
// 		} catch {
// 			data = { message: "Invalid JSON response" };
// 		}
// 		console.log(data);
// 	} catch (error) {
// 		console.error("Error sending data:", error);
// 	}
// };
