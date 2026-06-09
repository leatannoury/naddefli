/**
 * NADDEFLI — serviceImage.js
 * Layer: Admin — Utility
 * Purpose: Builds full image URL from API base + upload path.
 * Connects to: Services page
 */

const API_ORIGIN = 'http://localhost:5000';

/**
 * Resolve service image URL for display in the admin dashboard.
 * The backend's formatServiceRecord() returns an `image_url` field
 * that is already a fully resolved URL — use it first.
 * Falls back to resolving the raw `image` field.
 */
export const resolveServiceImage = (service) => {
  if (!service) return null;

  // Prefer the pre-resolved image_url returned by the backend
  if (service.image_url && typeof service.image_url === 'string') {
    const url = service.image_url.trim();
    if (url) return url;
  }

  // Fallback: resolve raw image field
  const image = service.image;
  if (!image || typeof image !== 'string') return null;
  const trimmed = image.trim();
  if (!trimmed) return null;

  // Already a full URL or data URI — return as-is
  if (/^https?:\/\//i.test(trimmed) || trimmed.startsWith('data:image')) {
    return trimmed;
  }

  // Relative path — build from API_ORIGIN
  const normalized = trimmed.replace(/^\//, '');
  if (normalized.startsWith('uploads/')) {
    return `${API_ORIGIN}/${normalized}`;
  }
  return `${API_ORIGIN}/uploads/${normalized}`;
};
