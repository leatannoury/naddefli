/**
 * NADDEFLI — MainLayout.jsx
 * Layer: Admin — Layout
 * Purpose: Sidebar + Navbar wrapper around page content.
 * Connects to: Sidebar, Navbar components
 */

import React, { useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Box, CssBaseline } from '@mui/material';
import Sidebar, { DRAWER_WIDTH } from '../components/Sidebar';
import Navbar from '../components/Navbar';

const MainLayout = () => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const getPageTitle = () => {
    switch (location.pathname) {
      case '/': return 'Operations Overview';
      case '/bookings': return 'Bookings Operations';
      case '/customers': return 'Client Directory';
      case '/services': return 'Service Offerings';
      case '/promos': return 'Promo Campaigns';
      case '/notifications': return 'Activity Alerts';
      case '/analytics': return 'System Analytics';
      case '/settings': return 'System Configurations';
      default: return 'Naddefli Admin';
    }
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: '#f6f9fc' }}>
      <CssBaseline />

      <Sidebar mobileOpen={mobileOpen} handleDrawerToggle={handleDrawerToggle} />

      <Box
        sx={{
          flexGrow: 1,
          display: 'flex',
          flexDirection: 'column',
          minHeight: '100vh',
          width: { lg: `calc(100% - ${DRAWER_WIDTH}px)` },
        }}
      >
        <Navbar handleDrawerToggle={handleDrawerToggle} title={getPageTitle()} />

        <Box
          component="main"
          sx={{
            flexGrow: 1,
            display: 'flex',
            justifyContent: 'center',
            px: { xs: 2.5, sm: 4 },
            py: { xs: 2.5, sm: 3 },
          }}
        >
          <Box sx={{ width: '100%', maxWidth: 1320 }} className="animate-fade-in">
            <Outlet />
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export default MainLayout;