/**
 * NADDEFLI — ProtectedRoute.jsx
 * Layer: Admin — Route Guard
 * Purpose: Redirects to /login if admin is not authenticated.
 * Connects to: AuthContext
 */

import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import LoadingScreen from '../components/LoadingScreen';

const ProtectedRoute = ({ children }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return <LoadingScreen message="Verifying administrative session..." />;
  }

  if (!user || user.role !== 'admin') {
    // Force logout/clear just in case and redirect
    return <Navigate to="/login" replace />;
  }

  return children;
};

export default ProtectedRoute;
