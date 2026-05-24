import React, { useState, useEffect, useCallback } from 'react';
import { Box, Grid, Card, Typography, Button, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper } from '@mui/material';
import {
  CalendarMonth,
  PendingActions,
  CheckCircleOutlined,
  CancelOutlined,
  PeopleAlt,
  AttachMoney,
  ConfirmationNumber,
  RefreshOutlined,
} from '@mui/icons-material';
import { dashboardAPI } from '../services/api';
import StatCard from '../components/StatCard';
import DateFilterBar, { todayStr } from '../components/DateFilterBar';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalCleaners: 0,
    totalBookings: 0,
    pendingBookings: 0,
    pendingBookingsAllTime: 0,
    completedBookings: 0,
    cancelledBookings: 0,
    acceptedBookings: 0,
    totalRevenue: '0.00',
    promoCodesUsed: 0,
  });
  const [recentBookings, setRecentBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filterMode, setFilterMode] = useState('today');
  const [startDate, setStartDate] = useState(todayStr());
  const [endDate, setEndDate] = useState(todayStr());

  const buildParams = useCallback(() => {
    const params = { filterMode, dateField: 'booking_date' };
    if (filterMode === 'today') {
      const t = todayStr();
      params.startDate = t;
      params.endDate = t;
    } else if (filterMode === 'range') {
      params.startDate = startDate;
      params.endDate = endDate;
    }
    return params;
  }, [filterMode, startDate, endDate]);

  const fetchDashboardData = useCallback(async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await dashboardAPI.getStats(buildParams());
      if (res && res.success) {
        setStats(res.data.stats);
        setRecentBookings(res.data.recentBookings || []);
      }
    } catch (error) {
      console.error('Failed to load dashboard statistics:', error);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [buildParams]);

  useEffect(() => {
    fetchDashboardData();
  }, [fetchDashboardData]);

  useEffect(() => {
    const interval = setInterval(() => fetchDashboardData(true), 5000);
    return () => clearInterval(interval);
  }, [fetchDashboardData]);

  const handleFilterModeChange = (mode) => {
    setFilterMode(mode);
    if (mode === 'today') {
      const t = todayStr();
      setStartDate(t);
      setEndDate(t);
    }
  };

  const handleNavigate = (path, state = {}) => () => {
    navigate(path, { state: { ...state, filterMode, startDate, endDate } });
  };

  const periodSubtitle =
    filterMode === 'all'
      ? 'All scheduled bookings'
      : filterMode === 'today'
        ? "Today's schedule"
        : 'Selected date range';

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Operational Overview
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Cleanings and reservations by schedule date. Updates every 5 seconds.
          </Typography>
        </Box>
        <Button
          variant="outlined"
          startIcon={<RefreshOutlined />}
          onClick={() => fetchDashboardData()}
          disabled={isRefreshing}
          sx={{ textTransform: 'none', borderColor: '#e6ebf1' }}
        >
          {isRefreshing ? 'Refreshing…' : 'Refresh'}
        </Button>
      </Box>

      <DateFilterBar
        filterMode={filterMode}
        startDate={startDate}
        endDate={endDate}
        onFilterModeChange={handleFilterModeChange}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
      />

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Scheduled Bookings"
            value={stats.totalBookings}
            icon={<CalendarMonth />}
            color="#635bff"
            subtitle={periodSubtitle}
            onClick={handleNavigate('/bookings', { initialTab: 'all' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Pending Approval"
            value={stats.pendingBookings}
            icon={<PendingActions />}
            color="#f5a623"
            subtitle={filterMode === 'all' ? 'All pending requests' : `${periodSubtitle} · ${stats.pendingBookingsAllTime} total pending`}
            onClick={handleNavigate('/bookings', { initialTab: 'pending' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Completed Jobs"
            value={stats.completedBookings}
            icon={<CheckCircleOutlined />}
            color="#00d4b6"
            subtitle={periodSubtitle}
            onClick={handleNavigate('/bookings', { initialTab: 'completed' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Cancelled"
            value={stats.cancelledBookings}
            icon={<CancelOutlined />}
            color="#ff5f5f"
            subtitle={periodSubtitle}
            onClick={handleNavigate('/bookings', { initialTab: 'cancelled' })}
          />
        </Grid>

        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Total Customers"
            value={stats.totalUsers}
            icon={<PeopleAlt />}
            color="#00bcd4"
            subtitle="Registered users (all time)"
            onClick={handleNavigate('/customers')}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Revenue"
            value={`$${parseFloat(stats.totalRevenue).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
            icon={<AttachMoney />}
            color="#00d4b6"
            subtitle={filterMode === 'all' ? 'All completed jobs' : `Completed jobs · ${periodSubtitle}`}
            onClick={handleNavigate('/analytics')}
          />
        </Grid>
        <Grid item xs={12} sm={12} md={4}>
          <StatCard
            title="Promo Codes Used"
            value={stats.promoCodesUsed}
            icon={<ConfirmationNumber />}
            color="#635bff"
            subtitle={periodSubtitle}
            onClick={handleNavigate('/promos')}
          />
        </Grid>
      </Grid>

      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        <Box sx={{ px: 3, py: 2.5, display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #e6ebf1' }}>
          <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540' }}>
            {filterMode === 'today' ? "Today's Schedule" : filterMode === 'all' ? 'Recent Bookings' : 'Bookings in Range'}
          </Typography>
          <Button size="small" onClick={() => navigate('/bookings')} sx={{ textTransform: 'none', color: '#635bff', fontWeight: 600 }}>
            View all
          </Button>
        </Box>
        <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
          <Table sx={{ minWidth: 650 }}>
            <TableHead sx={{ bgcolor: '#f6f9fc' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>ID</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Customer</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Service</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Schedule</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Price</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Status</TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#697386', pr: 3 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 4, color: '#697386' }}>Loading…</TableCell>
                </TableRow>
              ) : recentBookings.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 4, color: '#697386' }}>No bookings for this period.</TableCell>
                </TableRow>
              ) : (
                recentBookings.map((row) => (
                  <TableRow key={row.id} sx={{ '&:hover': { bgcolor: '#f6f9fc' } }}>
                    <TableCell sx={{ fontWeight: 600, fontSize: '0.82rem' }}>#{String(row.id || '').slice(0, 8)}</TableCell>
                    <TableCell>{row.customer?.full_name || 'Guest'}</TableCell>
                    <TableCell>{row.service?.name || 'Cleaning'}</TableCell>
                    <TableCell sx={{ fontSize: '0.85rem' }}>
                      {new Date(row.booking_date).toLocaleDateString()} at {row.booking_time}
                    </TableCell>
                    <TableCell sx={{ fontWeight: 700 }}>${parseFloat(row.total_price).toFixed(2)}</TableCell>
                    <TableCell><span className={`status-badge ${row.status}`}>{row.status}</span></TableCell>
                    <TableCell align="right" sx={{ pr: 3 }}>
                      <Button size="small" onClick={() => navigate('/bookings', { state: { highlightBookingId: row.id } })} sx={{ textTransform: 'none', color: '#635bff', fontWeight: 600 }}>
                        Manage
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Card>
    </Box>
  );
};

export default Dashboard;
