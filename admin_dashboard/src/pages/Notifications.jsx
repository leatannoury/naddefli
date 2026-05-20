import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  Typography,
  Button,
  Stack,
  Divider,
  Avatar,
  Badge,
  IconButton
} from '@mui/material';
import {
  RefreshOutlined,
  NotificationsNoneOutlined,
  CalendarMonth,
  PersonOutlined,
  AttachMoney,
  CheckCircleOutlined,
  InfoOutlined,
  DeleteOutlined
} from '@mui/icons-material';
import { bookingsAPI } from '../services/api';

const Notifications = () => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const fetchSystemActivities = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const lastSeenAt = parseInt(localStorage.getItem('naddefli_notifications_last_seen') || '0', 10);
      const res = await bookingsAPI.getAll();
      if (res && res.success) {
        const bookingsList = res.data || [];
        const derivedNotifs = [];

        bookingsList.forEach((b) => {
          const placedTime = new Date(b.created_at || new Date()).getTime();
          const status = placedTime > lastSeenAt ? 'unread' : 'read';

          derivedNotifs.push({
            id: `placed-${b.id}`,
            title: 'New Booking Placed',
            body: `${b.customer?.full_name || 'A customer'} requested a new ${b.cleaning_type === 'deep' ? 'Deep' : 'Standard'} cleaning at ${b.address}, ${b.city}.`,
            time: new Date(b.created_at || new Date()),
            type: 'booking_placed',
            status,
            icon: <CalendarMonth sx={{ color: '#635bff' }} />,
            color: '#635bff0f'
          });

          if (b.status === 'accepted' || b.status === 'completed') {
            derivedNotifs.push({
              id: `accepted-${b.id}`,
              title: 'Booking Approved',
              body: `Booking #${String(b.id || '').slice(0, 8)} has been approved by the admin and is ready for fulfillment.`,
              time: new Date(b.booking_date),
              type: 'booking_accepted',
              status: 'read',
              icon: <PersonOutlined sx={{ color: '#00bcd4' }} />,
              color: '#00bcd40f'
            });
          }

          if (b.status === 'completed') {
            derivedNotifs.push({
              id: `completed-${b.id}`,
              title: 'Cleaning Service Fulfilled',
              body: `Cleaner successfully fulfilled cleaning job #${String(b.id || '').slice(0, 8)} for ${b.customer?.full_name}. Net income of $${parseFloat(b.total_price).toFixed(2)} credited.`,
              time: new Date(b.booking_date),
              type: 'booking_completed',
              status: 'read',
              icon: <CheckCircleOutlined sx={{ color: '#00d4b6' }} />,
              color: '#00d4b60f'
            });
          }
        });

        derivedNotifs.push({
          id: 'sys-update-1',
          title: 'Database Auto-Migration Successful',
          body: 'Sequelize synchronizer checked columns matching model updates and loaded active/blocked attributes.',
          time: new Date(Date.now() - 3600000),
          type: 'system',
          status: 'read',
          icon: <InfoOutlined sx={{ color: '#f5a623' }} />,
          color: '#f5a6230f'
        });

        derivedNotifs.sort((a, b) => b.time - a.time);
        const unreadCount = derivedNotifs.filter((item) => item.status === 'unread').length;

        setNotifications(derivedNotifs);
        localStorage.setItem('naddefli_notifications_unread', unreadCount.toString());
        localStorage.setItem('naddefli_notifications_last_seen', Date.now().toString());
        window.dispatchEvent(new Event('naddefliNotificationsUpdated'));
      }
    } catch (err) {
      console.error('Failed to sync administrative notification triggers:', err);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchSystemActivities();
  }, []);

  const handleManualRefresh = () => {
    fetchSystemActivities();
  };

  const handleMarkAllRead = () => {
    setNotifications((prev) => {
      const updated = prev.map((n) => ({ ...n, status: 'read' }));
      localStorage.setItem('naddefli_notifications_unread', '0');
      window.dispatchEvent(new Event('naddefliNotificationsUpdated'));
      return updated;
    });
  };

  const handleDeleteNotif = (id) => {
    setNotifications((prev) => {
      const updated = prev.filter((n) => n.id !== id);
      const unreadLeft = updated.filter((n) => n.status === 'unread').length;
      localStorage.setItem('naddefli_notifications_unread', unreadLeft.toString());
      window.dispatchEvent(new Event('naddefliNotificationsUpdated'));
      return updated;
    });
  };

  const unreadCount = notifications.filter((n) => n.status === 'unread').length;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
              Activity Alerts
            </Typography>
            {unreadCount > 0 && (
              <Badge badgeContent={unreadCount} color="error" sx={{ '& .MuiBadge-badge': { fontSize: '0.8rem', height: 20, minWidth: 20 } }} />
            )}
          </Box>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Consolidated platform activities, booking triggers, staff updates, and operations audits.
          </Typography>
        </Box>
        <Stack direction="row" spacing={1.5}>
          <Button
            variant="outlined"
            startIcon={<RefreshOutlined />}
            onClick={handleManualRefresh}
            disabled={isRefreshing}
            sx={{
              borderColor: '#e6ebf1',
              color: '#0A2540',
              textTransform: 'none',
              px: 2.5,
              py: 1.2,
              borderRadius: '8px',
              bgcolor: '#fff',
              fontWeight: 600,
              '&:hover': { borderColor: '#635bff', bgcolor: '#f6f9fc' }
            }}
          >
            {isRefreshing ? 'Refreshing...' : 'Refresh'}
          </Button>
          <Button
            variant="contained"
            onClick={handleMarkAllRead}
            disabled={unreadCount === 0}
            sx={{
              bgcolor: '#0A2540',
              textTransform: 'none',
              boxShadow: 'none',
              px: 2.5,
              py: 1.2,
              borderRadius: '8px',
              fontWeight: 600,
              '&:hover': { bgcolor: '#635bff' }
            }}
          >
            Mark All Read
          </Button>
        </Stack>
      </Box>

      {/* Alerts Ledger Card */}
      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        <Stack divider={<Divider />} sx={{ minHeight: 400 }}>
          {loading && notifications.length === 0 ? (
            <Box sx={{ p: 8, textAlign: 'center', color: '#697386' }}>
              Synthesizing platform alerts...
            </Box>
          ) : notifications.length === 0 ? (
            <Box sx={{ p: 8, textAlign: 'center', color: '#697386' }}>
              No recent notifications generated.
            </Box>
          ) : (
            notifications.map((n) => (
              <Box
                key={n.id}
                sx={{
                  p: 3,
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  bgcolor: n.status === 'unread' ? '#635bff03' : 'transparent',
                  transition: 'background-color 0.2s ease',
                  '&:hover': {
                    bgcolor: n.status === 'unread' ? '#635bff06' : '#f8fafc'
                  }
                }}
              >
                <Box sx={{ display: 'flex', gap: 2.5, alignItems: 'flex-start' }}>
                  <Avatar sx={{ bgcolor: n.color, width: 44, height: 44 }}>
                    {n.icon}
                  </Avatar>
                  <Box>
                    <Typography variant="subtitle1" sx={{ fontWeight: 700, color: '#0A2540', mb: 0.5, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                      {n.title}
                      {n.status === 'unread' && (
                        <Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: '#ff5f5f' }} />
                      )}
                    </Typography>
                    <Typography variant="body2" sx={{ color: '#424e5e', mb: 1, maxWidth: 650 }}>
                      {n.body}
                    </Typography>
                    <Typography variant="caption" sx={{ color: '#cbd5e1', fontWeight: 600 }}>
                      {n.time.toLocaleString()}
                    </Typography>
                  </Box>
                </Box>

                <IconButton size="small" onClick={() => handleDeleteNotif(n.id)} sx={{ color: '#cbd5e1', '&:hover': { color: '#ff5f5f' } }}>
                  <DeleteOutlined fontSize="small" />
                </IconButton>
              </Box>
            ))
          )}
        </Stack>
      </Card>
    </Box>
  );
};

export default Notifications;
