import React, { createContext, useState, useEffect, useContext } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initializeAuth = async () => {
      const storedToken = localStorage.getItem('naddefli_admin_token');
      const storedUser = localStorage.getItem('naddefli_admin_user');

      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
        
        // Optionally verify token validity by fetching latest profile
        try {
          const profile = await authAPI.getProfile();
          if (profile && profile.success) {
            // Update profile info
            const updatedUser = {
              id: profile.data.id,
              full_name: profile.data.full_name,
              email: profile.data.email,
              role: profile.data.role
            };
            setUser(updatedUser);
            localStorage.setItem('naddefli_admin_user', JSON.stringify(updatedUser));
          }
        } catch (err) {
          console.warn('Failed to verify stored session:', err.message);
          // Token might be expired, clear it
          logout();
        }
      }
      setLoading(false);
    };

    initializeAuth();
  }, []);

  const login = async (email, password) => {
    try {
      const res = await authAPI.login(email, password);
      if (res && res.success && res.data.user.role === 'admin') {
        const { token, user } = res.data;
        setToken(token);
        setUser(user);
        localStorage.setItem('naddefli_admin_token', token);
        localStorage.setItem('naddefli_admin_user', JSON.stringify(user));
        return { success: true };
      } else {
        return { success: false, message: 'Invalid role. Administrator only.' };
      }
    } catch (error) {
      console.error('Context login error:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Login failed. Please check your credentials.'
      };
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('naddefli_admin_token');
    localStorage.removeItem('naddefli_admin_user');
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
