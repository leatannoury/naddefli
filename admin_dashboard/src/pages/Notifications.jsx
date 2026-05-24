import React, { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Card,
  Typography,
  Button,
  Stack,
  Divider,
  Avatar,
  IconButton,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material';
import {
  RefreshOutlined,
  CalendarMonth,
  CheckCircleOutlined,
  DeleteOutlined,
} from '@mui/icons-material';
import { bookingsAPI } from '../services/api';
import DateFilterBar, { todayStr } from '../components/DateFilterBar';

const markNotificationsSeen = () => {
  localStorage.setItem('naddefli_notifications_last_seen', Date.now().toString());
  window.dispatchEvent(new Event('naddefliNotificationsUpdated'));
};

const Notifications = () => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filterMode, setFilterMode] = useState('all');
  const [startDate, setStartDate] = useState(todayStr());
  const [endDate, setEndDate] = useState(todayStr());
  const [sortOrder, setSortOrder] = useState('newest');

  const buildParams = useCallback(() => {
    const params = { filterMode: 'all' };
    if (filterMode === 'today') {
      const t = todayStr();
      params.filterMode = 'today';
      params.startDate = t;
      params.endDate = t;
    } else if (filterMode === 'range') {
      params.filterMode = 'range';
      params.startDate = startDate;
      params.endDate = endDate;
    }
    return params;
  }, [filterMode, startDate, endDate]);

  const fetchSystemActivities = useCallback(async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const lastSeenAt = parseInt(localStorage.getItem('naddefli_notifications_last_seen') || '0', 10);
      const res = await bookingsAPI.getAll(buildParams());
      if (res && res.success) {
        const bookingsList = res.data || [];
        const derivedNotifs = [];

        bookingsList.forEach((b) => {
          const placedTime = new Date(b.created_at || new Date());
          const isUnread = placedTime.getTime() > lastSeenAt;

          derivedNotifs.push({
            id: `placed-${b.id}`,
            title: 'New Booking',
            body: `${b.customer?.full_name || 'A customer'} booked ${b.service?.name || 'a cleaning'} for ${new Date(b.booking_date).toLocaleDateString()} at ${b.booking_time}.`,
            time: placedTime,
            type: 'booking_placed',
            status: isUnread ? 'unread' : 'read',
            icon: <CalendarMonth sx={{ color: '#635bff' }} />,
            color: '#635bff0f',
          });

          if (b.status === 'completed') {
            derivedNotifs.push({
              id: `completed-${b.id}`,
              title: 'Job Completed',
              body: `Booking #${String(b.id).slice(0, 8)} completed — $${parseFloat(b.total_price).toFixed(2)} revenue.`,
              time: new Date(b.updated_at || b.booking_date),
              type: 'booking_completed',
              status: 'read',
              icon: <CheckCircleOutlined sx={{ color: '#00d4b6' }} />,
              color: '#00d4b60f',
            });
          }
        });

        derivedNotifs.sort((a, b) => {
          if (sortOrder === 'oldest') return a.time - b.time;
          return b.time - a.time;
        });

        setNotifications(derivedNotifs);
      }
    } catch (err) {
      console.error('Failed to load notifications:', err);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [buildParams, sortOrder]);

  useEffect(() => {
    fetchSystemActivities().then(() => markNotificationsSeen());
  }, [fetchSystemActivities]);

  useEffect(() => {
    const interval = setInterval(() => fetchSystemActivities(true), 10000);
    return () => clearInterval(interval);
  }, [fetchSystemActivities]);

  const handleFilterModeChange = (mode) => {
    setFilterMode(mode);
    if (mode === 'today') {
      const t = todayStr();
      setStartDate(t);
      setEndDate(t);
    }
  };

  const handleDeleteNotif = (id) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540' }}>
            Notifications
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Booking activity sorted by newest. Opening this page clears the bell badge.
          </Typography>
        </Box>
        <Button variant="outlined" startIcon={<RefreshOutlined />} onClick={() => fetchSystemActivities()} disabled={isRefreshing} sx={{ textTransform: 'none' }}>
          Refresh
        </Button>
      </Box>

      <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems={{ sm: 'center' }}>
        <DateFilterBar
          filterMode={filterMode}
          startDate={startDate}
          endDate={endDate}
          showAllTime
          onFilterModeChange={handleFilterModeChange}
          onStartDateChange={setStartDate}
          onEndDateChange={setEndDate}
        />
        <FormControl size="small" sx={{ minWidth: 160 }}>
          <InputLabel>Sort</InputLabel>
          <Select label="Sort" value={sortOrder} onChange={(e) => setSortOrder(e.target.value)}>
            <MenuItem value="newest">Newest first</MenuItem>
            <MenuItem value="oldest">Oldest first</MenuItem>
          </Select>
        </FormControl>
      </Stack>

      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        <Stack divider={<Divider />}>
          {loading && notifications.length === 0 ? (
            <Box sx={{ p: 8, textAlign: 'center', color: '#697386' }}>Loading…</Box>
          ) : notifications.length === 0 ? (
            <Box sx={{ p: 8, textAlign: 'center', color: '#697386' }}>No notifications for this period.</Box>
          ) : (
            notifications.map((n) => (
              <Box
                key={n.id}
                sx={{
                  p: 3,
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  bgcolor: n.status === 'unread' ? '#635bff06' : 'transparent',
                }}
              >
                <Box sx={{ display: 'flex', gap: 2.5 }}>
                  <Avatar sx={{ bgcolor: n.color, width: 44, height: 44 }}>{n.icon}</Avatar>
                  <Box>
                    <Typography variant="subtitle1" sx={{ fontWeight: 700, color: '#0A2540', mb: 0.5 }}>
                      {n.title}
                      {n.status === 'unread' && (
                        <Box component="span" sx={{ ml: 1, width: 8, height: 8, borderRadius: '50%', bgcolor: '#ff5f5f', display: 'inline-block' }} />
                      )}
                    </Typography>
                    <Typography variant="body2" sx={{ color: '#424e5e', mb: 1, maxWidth: 650 }}>{n.body}</Typography>
                    <Typography variant="caption" sx={{ color: '#a3b1c2', fontWeight: 600 }}>{n.time.toLocaleString()}</Typography>
                  </Box>
                </Box>
                <IconButton size="small" onClick={() => handleDeleteNotif(n.id)} sx={{ color: '#cbd5e1' }}>
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
