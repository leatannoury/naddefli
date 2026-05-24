const API_ORIGIN = 'http://localhost:5000';

export const resolveServiceImage = (service) => {
  if (!service) return null;
  if (service.image_url) return service.image_url;
  const image = service.image;
  if (!image || typeof image !== 'string') return null;
  const trimmed = image.trim();
  if (!trimmed) return null;
  if (/^https?:\/\//i.test(trimmed) || trimmed.startsWith('data:image')) {
    return trimmed;
  }
  const normalized = trimmed.replace(/^\//, '');
  if (normalized.startsWith('uploads/')) {
    return `${API_ORIGIN}/${normalized}`;
  }
  return `${API_ORIGIN}/uploads/${normalized}`;
};
