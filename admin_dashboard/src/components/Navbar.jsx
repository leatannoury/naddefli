import React, { useState, useEffect } from 'react';
import { AppBar, Toolbar, IconButton, Badge, Box, Avatar, Typography, Menu, MenuItem, ListItemIcon, ListItemText, Divider } from '@mui/material';
import {
  Menu as MenuIcon,
  NotificationsNoneOutlined,
  LogoutOutlined,
  PersonOutlineOutlined,
  SettingsOutlined
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { notificationsAPI } from '../services/api';
import { useNavigate } from 'react-router-dom';

const Navbar = ({ handleDrawerToggle, title = 'Overview' }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState(null);
  const [notificationCount, setNotificationCount] = useState(0);

  const fetchNotificationCount = async () => {
    try {
      const res = await notificationsAPI.getUnread();
      if (res && res.success) {
        setNotificationCount(res.data.unreadCount ?? 0);
      } else {
        setNotificationCount(0);
      }
    } catch (err) {
      console.error('Failed to fetch notifications:', err);
      setNotificationCount(0);
    }
  };

  useEffect(() => {
    fetchNotificationCount();
    const interval = setInterval(fetchNotificationCount, 15000);
    const onUpdate = () => fetchNotificationCount();
    window.addEventListener('naddefliNotificationsUpdated', onUpdate);
    return () => {
      clearInterval(interval);
      window.removeEventListener('naddefliNotificationsUpdated', onUpdate);
    };
  }, []);


  const handleMenuOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    handleMenuClose();
    logout();
  };

  const handleProfileClick = () => {
    handleMenuClose();
    navigate('/settings');
  };

  return (
    <AppBar
      position="sticky"
      sx={{
        bgcolor: 'rgba(246, 249, 252, 0.8)',
        backdropFilter: 'blur(12px)',
        boxShadow: 'none',
        borderBottom: '1px solid #e6ebf1',
        color: '#0A2540',
        width: '100%',
        zIndex: (theme) => theme.zIndex.drawer + 1,
      }}
    >
      <Toolbar sx={{ justifyContent: 'space-between', px: { xs: 2, sm: 3 } }}>
        {/* Left Side: Hamburger & Title */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <IconButton
            color="inherit"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 1, display: { lg: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography
            variant="h5"
            sx={{
              fontWeight: 700,
              letterSpacing: '-0.03em',
              display: { xs: 'none', sm: 'block' }
            }}
          >
            {title}
          </Typography>
        </Box>

        {/* Right Side: Notifications & Profile */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          {/* Notifications */}
          <IconButton
            size="large"
            color="inherit"
            onClick={() => navigate('/notifications')}
            sx={{
              border: '1px solid #e6ebf1',
              bgcolor: '#fff',
              p: 1,
              '&:hover': { bgcolor: '#f6f9fc' }
            }}
          >
            <Badge badgeContent={notificationCount} color="error" showZero={false}>
              <NotificationsNoneOutlined sx={{ fontSize: 22 }} />
            </Badge>
          </IconButton>

          {/* Profile Dropdown */}
          <Box
            onClick={handleMenuOpen}
            sx={{
              display: 'flex',
              alignItems: 'center',
              gap: 1,
              cursor: 'pointer',
              p: 0.5,
              borderRadius: '50px',
              border: '1px solid #e6ebf1',
              bgcolor: '#fff',
              pr: 1.5,
              '&:hover': { bgcolor: '#f6f9fc' },
              transition: 'all 0.2s ease'
            }}
          >
            <Avatar
              sx={{
                width: 32,
                height: 32,
                bgcolor: '#635bff',
                fontSize: '0.85rem',
                fontWeight: 700
              }}
            >
              {user?.full_name?.charAt(0).toUpperCase() || 'A'}
            </Avatar>
            <Box sx={{ display: { xs: 'none', md: 'block' } }}>
              <Typography variant="body2" sx={{ fontWeight: 600, fontSize: '0.82rem', lineHeight: 1.2 }}>
                {user?.full_name || 'Admin'}
              </Typography>
              <Typography variant="caption" sx={{ color: '#697386', fontSize: '0.72rem', display: 'block', mt: -0.2 }}>
                System Admin
              </Typography>
            </Box>
          </Box>

          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleMenuClose}
            transformOrigin={{ horizontal: 'right', vertical: 'top' }}
            anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
            PaperProps={{
              elevation: 0,
              sx: {
                overflow: 'visible',
                filter: 'drop-shadow(0px 2px 10px rgba(0,0,0,0.06))',
                mt: 1.5,
                border: '1px solid #e6ebf1',
                borderRadius: '10px',
                width: 220,
                '& .MuiAvatar-root': {
                  width: 32,
                  height: 32,
                  ml: -0.5,
                  mr: 1,
                },
              },
            }}
          >
            <Box sx={{ px: 2, py: 1.5 }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                {user?.full_name || 'Admin User'}
              </Typography>
              <Typography variant="caption" sx={{ color: '#697386', wordBreak: 'break-all' }}>
                {user?.email || 'admin@test.com'}
              </Typography>
            </Box>
            <Divider />
            <MenuItem onClick={handleProfileClick} sx={{ py: 1 }}>
              <ListItemIcon sx={{ color: '#697386' }}>
                <SettingsOutlined fontSize="small" />
              </ListItemIcon>
              <ListItemText primary="Account Settings" primaryTypographyProps={{ fontSize: '0.88rem' }} />
            </MenuItem>
            <Divider />
            <MenuItem onClick={handleLogout} sx={{ color: '#ff5f5f', py: 1 }}>
              <ListItemIcon sx={{ color: '#ff5f5f' }}>
                <LogoutOutlined fontSize="small" />
              </ListItemIcon>
              <ListItemText primary="Sign Out" primaryTypographyProps={{ fontSize: '0.88rem', fontWeight: 600 }} />
            </MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;
