/**
 * NADDEFLI — Login.jsx
 * Layer: Admin — Page
 * Purpose: Admin login form.
 * Connects to: AuthContext → POST /api/admin/login
 */

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Card, TextField, Button, Typography, InputAdornment, IconButton, Alert, CircularProgress } from '@mui/material';
import { Visibility, VisibilityOff, LockOutlined, EmailOutlined } from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setErrorMsg('Please enter both email and password.');
      return;
    }

    setErrorMsg('');
    setSubmitting(true);

    const res = await login(email, password);
    if (res.success) {
      navigate('/');
    } else {
      setErrorMsg(res.message || 'Login failed.');
      setSubmitting(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #0A2540 0%, #1A3E66 100%)',
        p: 2,
        position: 'relative',
        overflow: 'hidden'
      }}
    >
      {/* Decorative colored blobs */}
      <Box
        sx={{
          position: 'absolute',
          top: '-15%',
          right: '-10%',
          width: '500px',
          height: '500px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(99,91,255,0.18) 0%, rgba(99,91,255,0) 70%)',
          zIndex: 1
        }}
      />
      <Box
        sx={{
          position: 'absolute',
          bottom: '-10%',
          left: '-10%',
          width: '400px',
          height: '400px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(0,212,182,0.1) 0%, rgba(0,212,182,0) 70%)',
          zIndex: 1
        }}
      />

      <Card
        elevation={24}
        sx={{
          maxWidth: 440,
          width: '100%',
          p: { xs: 4, sm: 5 },
          borderRadius: '16px',
          bgcolor: 'rgba(255, 255, 255, 0.95)',
          backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255, 255, 255, 0.3)',
          zIndex: 2,
          boxShadow: '0 20px 40px rgba(0,0,0,0.3)',
          animation: 'fadeIn 0.5s ease-out'
        }}
      >
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
          <Box
            sx={{
              width: 52,
              height: 52,
              borderRadius: '12px',
              bgcolor: '#635bff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              mb: 2,
              boxShadow: '0 4px 15px rgba(99, 91, 255, 0.4)'
            }}
          >
            <Typography variant="h5" sx={{ fontWeight: 900, color: '#fff' }}>
              N
            </Typography>
          </Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Naddefli Admin
          </Typography>
          <Typography variant="body2" sx={{ color: '#697386', mt: 0.5, fontWeight: 500 }}>
            Sign in to access your operations dashboard
          </Typography>
        </Box>

        {errorMsg && (
          <Alert severity="error" sx={{ mb: 3, borderRadius: '8px', fontSize: '0.85rem' }}>
            {errorMsg}
          </Alert>
        )}

        <form onSubmit={handleSubmit}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
            <TextField
              label="Email Address"
              type="email"
              variant="outlined"
              fullWidth
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={submitting}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <EmailOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} />
                  </InputAdornment>
                ),
              }}
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: '8px',
                }
              }}
            />

            <TextField
              label="Password"
              type={showPassword ? 'text' : 'password'}
              variant="outlined"
              fullWidth
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={submitting}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <LockOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShowPassword(!showPassword)} edge="end">
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: '8px',
                }
              }}
            />

            <Button
              type="submit"
              variant="contained"
              fullWidth
              size="large"
              disabled={submitting}
              sx={{
                bgcolor: '#635bff',
                color: '#fff',
                fontWeight: 600,
                textTransform: 'none',
                py: 1.5,
                borderRadius: '8px',
                fontSize: '1rem',
                boxShadow: '0 4px 12px rgba(99, 91, 255, 0.25)',
                '&:hover': {
                  bgcolor: '#0A2540',
                  boxShadow: '0 6px 16px rgba(10, 37, 64, 0.2)',
                },
                transition: 'all 0.25s ease'
              }}
            >
              {submitting ? (
                <CircularProgress size={24} sx={{ color: '#fff' }} />
              ) : (
                'Secure Sign In'
              )}
            </Button>
          </Box>
        </form>
      </Card>
    </Box>
  );
};

export default Login;
