/**
 * NADDEFLI — LoadingScreen.jsx
 * Layer: Admin — Component
 * Purpose: Full-page loading spinner while data fetches.
 * Connects to: Used across pages
 */

import React from 'react';
import { Box, CircularProgress, Typography } from '@mui/material';

const LoadingScreen = ({ message = 'Loading Naddefli Portal...' }) => {
  return (
    <Box
      sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'rgba(246, 249, 252, 0.85)',
        backdropFilter: 'blur(8px)',
        zIndex: 9999,
      }}
    >
      <CircularProgress
        size={60}
        thickness={4}
        sx={{
          color: '#635bff',
          mb: 3,
        }}
      />
      <Typography
        variant="h6"
        sx={{
          color: '#0A2540',
          fontWeight: 600,
          letterSpacing: '-0.02em',
          animation: 'pulse 1.5s infinite ease-in-out',
          '@keyframes pulse': {
            '0%, 100%': { opacity: 0.6 },
            '50%': { opacity: 1 },
          },
        }}
      >
        {message}
      </Typography>
    </Box>
  );
};

export default LoadingScreen;
