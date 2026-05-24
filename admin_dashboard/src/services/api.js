import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to automatically inject JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('naddefli_admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle token expiry / unauthenticated
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Clear credentials and redirect to login if unauthorized
      localStorage.removeItem('naddefli_admin_token');
      localStorage.removeItem('naddefli_admin_user');
      // If we are on the web app and not on login page, reload to trigger redirect
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: async (email, password) => {
    const res = await api.post('/admin/login', { email, password });
    return res.data;
  },
  getProfile: async () => {
    const res = await api.get('/auth/profile');
    return res.data;
  }
};

export const dashboardAPI = {
  getStats: async (params = {}) => {
    const queryParams = new URLSearchParams();
    if (params.startDate) queryParams.append('startDate', params.startDate);
    if (params.endDate) queryParams.append('endDate', params.endDate);
    if (params.timeframe) queryParams.append('timeframe', params.timeframe);
    if (params.filterMode) queryParams.append('filterMode', params.filterMode);
    if (params.dateField) queryParams.append('dateField', params.dateField);

    const queryString = queryParams.toString();
    const url = `/admin/dashboard${queryString ? `?${queryString}` : ''}`;
    const res = await api.get(url);
    return res.data;
  }
};

export const bookingsAPI = {
  getAll: async (params = {}) => {
    const queryParams = new URLSearchParams();
    if (params.startDate) queryParams.append('startDate', params.startDate);
    if (params.endDate) queryParams.append('endDate', params.endDate);
    if (params.filterMode) queryParams.append('filterMode', params.filterMode);
    if (params.status) queryParams.append('status', params.status);
    const queryString = queryParams.toString();
    const url = `/admin/bookings${queryString ? `?${queryString}` : ''}`;
    const res = await api.get(url);
    return res.data;
  },
  getById: async (id) => {
    const res = await api.get(`/admin/bookings/${id}`);
    return res.data;
  },
  accept: async (id) => {
    const res = await api.put(`/admin/bookings/${id}/accept`);
    return res.data;
  },
  cancel: async (id, reason = '') => {
    const res = await api.put(`/admin/bookings/${id}/cancel`, { reason });
    return res.data;
  },
  complete: async (id) => {
    const res = await api.put(`/admin/bookings/${id}/complete`);
    return res.data;
  }
};

export const customersAPI = {
  getAll: async () => {
    const res = await api.get('/admin/customers');
    return res.data;
  },
  getById: async (id) => {
    const res = await api.get(`/admin/customers/${id}`);
    return res.data;
  },
  create: async (data) => {
    const res = await api.post('/admin/customers', data);
    return res.data;
  },
  update: async (id, data) => {
    const res = await api.put(`/admin/customers/${id}`, data);
    return res.data;
  },
  block: async (id, isBlocked) => {
    const res = await api.put(`/admin/customers/${id}/block`, { is_blocked: isBlocked });
    return res.data;
  },
  delete: async (id) => {
    const res = await api.delete(`/admin/customers/${id}`);
    return res.data;
  }
};

export const cleanersAPI = {
  getAll: async () => {
    const res = await api.get('/admin/cleaners');
    return res.data;
  }
};

export const servicesAPI = {
  getAll: async () => {
    const res = await api.get('/admin/services');
    return res.data;
  },
  create: async (data) => {
    const res = await api.post('/admin/services', data);
    return res.data;
  },
  update: async (id, data) => {
    const res = await api.put(`/admin/services/${id}`, data);
    return res.data;
  },
  delete: async (id) => {
    const res = await api.delete(`/admin/services/${id}`);
    return res.data;
  }
};

export const promosAPI = {
  getAll: async () => {
    const res = await api.get('/admin/promos');
    return res.data;
  },
  create: async (data) => {
    const res = await api.post('/admin/promos', data);
    return res.data;
  },
  update: async (id, data) => {
    const res = await api.put(`/admin/promos/${id}`, data);
    return res.data;
  },
  delete: async (id) => {
    const res = await api.delete(`/admin/promos/${id}`);
    return res.data;
  }
};

export const notificationsAPI = {
  getUnread: async () => {
    const lastSeen = localStorage.getItem('naddefli_notifications_last_seen') || '0';
    const res = await api.get(`/admin/notifications/unread?lastSeen=${lastSeen}`);
    return res.data;
  },
  getAll: async () => {
    const res = await api.get('/admin/notifications');
    return res.data;
  },
  markAsRead: async (id) => {
    const res = await api.put(`/admin/notifications/${id}/read`);
    return res.data;
  },
  markAllAsRead: async () => {
    const res = await api.put('/admin/notifications/read-all');
    return res.data;
  }
};

export const settingsAPI = {
  get: async () => {
    const res = await api.get('/admin/settings');
    return res.data;
  },
  update: async (data) => {
    const res = await api.put('/admin/settings', data);
    return res.data;
  }
};

export default api;
