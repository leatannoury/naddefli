/**
 * NADDEFLI — StatCard.jsx
 * Layer: Admin — Component
 * Purpose: Reusable metric card for dashboard stats.
 * Connects to: Dashboard page
 */

import React from 'react';
import { Card, Box, Typography } from '@mui/material';

const StatCard = ({ title, value, icon, color = '#635bff', subtitle = '', onClick }) => {
  return (
    <Card
      onClick={onClick}
      sx={{
        p: 2.5,
        borderRadius: '12px',
        border: '1px solid #e6ebf1',
        boxShadow: '0 2px 8px rgba(0,0,0,0.01)',
        bgcolor: '#fff',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        position: 'relative',
        overflow: 'hidden',
        transition: 'transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.2s ease, border-color 0.2s ease',
        cursor: onClick ? 'pointer' : 'default',
        '&:hover': {
          transform: onClick ? 'translateY(-4px)' : 'none',
          boxShadow: onClick ? '0 12px 24px rgba(0, 0, 0, 0.04)' : '0 2px 8px rgba(0,0,0,0.01)',
          borderColor: onClick ? '#cbd5e1' : '#e6ebf1',
          '& .icon-bg': {
            transform: onClick ? 'scale(1.1)' : 'none',
          }
        }
      }}
    >
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
        <Typography
          variant="subtitle2"
          sx={{
            color: '#697386',
            fontWeight: 600,
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
            fontSize: '0.72rem'
          }}
        >
          {title}
        </Typography>
        <Typography
          variant="h4"
          sx={{
            fontWeight: 700,
            color: '#0A2540',
            letterSpacing: '-0.03em'
          }}
        >
          {value}
        </Typography>
        {subtitle && (
          <Typography
            variant="caption"
            sx={{
              color: '#00d4b6',
              fontWeight: 600,
              fontSize: '0.75rem',
              mt: 0.5,
              display: 'flex',
              alignItems: 'center',
              gap: 0.5
            }}
          >
            {subtitle}
          </Typography>
        )}
      </Box>

      {/* Decorative Icon Container */}
      <Box
        className="icon-bg"
        sx={{
          width: 52,
          height: 52,
          borderRadius: '14px',
          bgcolor: `${color}12`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: color,
          transition: 'transform 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
          '& svg': {
            fontSize: 26
          }
        }}
      >
        {icon}
      </Box>
    </Card>
  );
};

export default StatCard;
