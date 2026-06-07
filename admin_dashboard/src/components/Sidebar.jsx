import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { Box, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Typography, Divider, Button } from '@mui/material';
import {
  DashboardOutlined,
  CalendarMonthOutlined,
  PeopleAltOutlined,
  CleaningServicesOutlined,
  ConfirmationNumberOutlined,
  NotificationsNoneOutlined,
  BarChartOutlined,
  SettingsOutlined,
  LogoutOutlined,
  LightbulbOutlined,
} from '@mui/icons-material';
import { Add } from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

const DRAWER_WIDTH = 260;

const Sidebar = ({ mobileOpen, handleDrawerToggle }) => {
  const { logout } = useAuth();
  const location = useLocation();

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardOutlined />, path: '/' },
    { text: 'Bookings', icon: <CalendarMonthOutlined />, path: '/bookings' },
    { text: 'Customers', icon: <PeopleAltOutlined />, path: '/customers' },
    { text: 'Services', icon: <CleaningServicesOutlined />, path: '/services' },
    { text: 'Promo Codes', icon: <ConfirmationNumberOutlined />, path: '/promos' },
    { text: 'Add-ons', icon: <Add />, path: '/addons' },
    { text: 'Cleaning Tips', icon: <LightbulbOutlined />, path: '/cleaning-tips' },
    { text: 'Notifications', icon: <NotificationsNoneOutlined />, path: '/notifications' },
    { text: 'Analytics', icon: <BarChartOutlined />, path: '/analytics' },
    { text: 'Settings', icon: <SettingsOutlined />, path: '/settings' },
  ];

  const drawerContent = (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column', bgcolor: '#0A2540', color: '#fff' }}>
      {/* Brand Header */}
      <Box sx={{ p: 3, display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Box
          sx={{
            width: 38,
            height: 38,
            borderRadius: '10px',
            bgcolor: '#635bff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(99, 91, 255, 0.3)'
          }}
        >
          <Typography variant="h6" sx={{ fontWeight: 800, color: '#fff', letterSpacing: '-0.05em' }}>
            N
          </Typography>
        </Box>
        <Box>
          <Typography variant="h6" sx={{ fontWeight: 700, letterSpacing: '-0.03em', lineHeight: 1.2 }}>
            Naddefli
          </Typography>
          <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.5)', fontWeight: 600 }}>
            ADMIN PORTAL
          </Typography>
        </Box>
      </Box>

      <Divider sx={{ borderColor: 'rgba(255,255,255,0.08)' }} />

      {/* Navigation List */}
      <Box sx={{ flexGrow: 1, px: 2, py: 3 }}>
        <List sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, p: 0 }}>
          {menuItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <ListItem key={item.text} disablePadding>
                <ListItemButton
                  component={NavLink}
                  to={item.path}
                  sx={{
                    borderRadius: '8px',
                    py: 1.2,
                    px: 2,
                    color: isActive ? '#fff' : 'rgba(255,255,255,0.65)',
                    bgcolor: isActive ? 'rgba(255,255,255,0.08)' : 'transparent',
                    '&:hover': {
                      bgcolor: 'rgba(255,255,255,0.04)',
                      color: '#fff',
                    },
                    '&.active': {
                      bgcolor: 'rgba(255,255,255,0.08)',
                      color: '#fff',
                      '& .MuiListItemIcon-root': {
                        color: '#635bff',
                      }
                    },
                    transition: 'all 0.2s ease',
                  }}
                >
                  <ListItemIcon
                    sx={{
                      color: isActive ? '#635bff' : 'rgba(255,255,255,0.45)',
                      minWidth: 40,
                      '& svg': { fontSize: 22 }
                    }}
                  >
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText
                    primary={item.text}
                    primaryTypographyProps={{
                      fontSize: '0.92rem',
                      fontWeight: isActive ? 600 : 500,
                    }}
                  />
                </ListItemButton>
              </ListItem>
            );
          })}
        </List>
      </Box>

      {/* Logout button at bottom */}
      <Box sx={{ p: 3 }}>
        <Button
          fullWidth
          variant="outlined"
          startIcon={<LogoutOutlined />}
          onClick={logout}
          sx={{
            borderColor: 'rgba(255,255,255,0.15)',
            color: 'rgba(255,255,255,0.7)',
            textTransform: 'none',
            py: 1.2,
            borderRadius: '8px',
            '&:hover': {
              borderColor: '#ff5f5f',
              color: '#ff5f5f',
              bgcolor: 'rgba(255, 95, 95, 0.05)'
            },
            transition: 'all 0.2s ease'
          }}
        >
          Logout
        </Button>
      </Box>
    </Box>
  );

  return (
    <Box
      component="nav"
      sx={{ width: { lg: DRAWER_WIDTH }, flexShrink: { lg: 0 } }}
    >
      {/* Mobile drawer */}
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={handleDrawerToggle}
        ModalProps={{ keepMounted: true }}
        sx={{
          display: { xs: 'block', lg: 'none' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: DRAWER_WIDTH, borderRight: 'none' },
        }}
      >
        {drawerContent}
      </Drawer>

      {/* Desktop drawer */}
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', lg: 'block' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: DRAWER_WIDTH, borderRight: 'none' },
        }}
        open
      >
        {drawerContent}
      </Drawer>
    </Box>
  );
};

export default Sidebar;
export { DRAWER_WIDTH };
