import React, { useState, useEffect } from 'react';
import { Box, Grid, Card, Typography, Button, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';
import {
  CalendarMonth,
  PendingActions,
  CheckCircleOutlined,
  CancelOutlined,
  PeopleAlt,
  AttachMoney,
  ConfirmationNumber,
  RefreshOutlined
} from '@mui/icons-material';
import { dashboardAPI } from '../services/api';
import StatCard from '../components/StatCard';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalCleaners: 0,
    totalBookings: 0,
    pendingBookings: 0,
    completedBookings: 0,
    cancelledBookings: 0,
    acceptedBookings: 0,
    totalRevenue: '0.00',
    promoCodesUsed: 0,
  });
  const [recentBookings, setRecentBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const fetchDashboardData = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await dashboardAPI.getStats();
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
  };

  useEffect(() => {
    // Initial fetch
    fetchDashboardData();

    // Auto-refresh polling every 5 seconds
    const interval = setInterval(() => {
      fetchDashboardData(true);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const handleManualRefresh = () => {
    fetchDashboardData();
  };

  const handleNavigate = (path, state = {}) => () => {
    navigate(path, { state });
  };


  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Operational Overview
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Real-time activity monitor (Updates automatically every 5s)
          </Typography>
        </Box>
        <Button
          variant="outlined"
          startIcon={<RefreshOutlined />}
          onClick={handleManualRefresh}
          disabled={isRefreshing}
          sx={{
            borderColor: '#e6ebf1',
            color: '#0A2540',
            textTransform: 'none',
            px: 2,
            py: 1,
            borderRadius: '8px',
            bgcolor: '#fff',
            boxShadow: '0 2px 4px rgba(0,0,0,0.01)',
            '&:hover': {
              borderColor: '#635bff',
              bgcolor: '#f6f9fc'
            }
          }}
        >
          {isRefreshing ? 'Refreshing...' : 'Refresh Now'}
        </Button>
      </Box>

      {/* KPI Cards Grid */}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Bookings"
            value={stats.totalBookings}
            icon={<CalendarMonth />}
            color="#635bff"
            subtitle="All time requests"
            onClick={handleNavigate('/bookings', { initialTab: 'all' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Pending Approval"
            value={stats.pendingBookings}
            icon={<PendingActions />}
            color="#f5a623"
            subtitle="Require response"
            onClick={handleNavigate('/bookings', { initialTab: 'pending' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Completed Jobs"
            value={stats.completedBookings}
            icon={<CheckCircleOutlined />}
            color="#00d4b6"
            subtitle="Fulfilled cleanings"
            onClick={handleNavigate('/bookings', { initialTab: 'completed' })}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Cancelled Jobs"
            value={stats.cancelledBookings}
            icon={<CancelOutlined />}
            color="#ff5f5f"
            subtitle="Discontinued cleans"
            onClick={handleNavigate('/bookings', { initialTab: 'cancelled' })}
          />
        </Grid>

        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Total Customers"
            value={stats.totalUsers}
            icon={<PeopleAlt />}
            color="#00bcd4"
            subtitle="Registered users"
            onClick={handleNavigate('/customers')}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Accrued Revenue"
            value={`$${parseFloat(stats.totalRevenue).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
            icon={<AttachMoney />}
            color="#00d4b6"
            subtitle="Paid transactions"
            onClick={handleNavigate('/analytics')}
          />
        </Grid>
        <Grid item xs={12} sm={12} md={4}>
          <StatCard
            title="Promo Codes Used"
            value={stats.promoCodesUsed}
            icon={<ConfirmationNumber />}
            color="#635bff"
            subtitle="Discounts claimed"
            onClick={handleNavigate('/promos')}
          />
        </Grid>
      </Grid>


      {/* Recent Bookings Table */}
      <Card
        sx={{
          borderRadius: '12px',
          border: '1px solid #e6ebf1',
          boxShadow: '0 2px 8px rgba(0,0,0,0.01)',
          overflow: 'hidden'
        }}
      >
        <Box sx={{ px: 3, py: 2.5, display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #e6ebf1' }}>
          <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', letterSpacing: '-0.02em' }}>
            Recent Bookings
          </Typography>
          <Button
            size="small"
            onClick={() => navigate('/bookings')}
            sx={{ textTransform: 'none', color: '#635bff', fontWeight: 600 }}
          >
            View All Bookings
          </Button>
        </Box>
        <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
          <Table sx={{ minWidth: 650 }}>
            <TableHead sx={{ bgcolor: '#f6f9fc' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Booking ID</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Customer</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Service Type</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Date / Time</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Price</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Status</TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#697386', pr: 3 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 4, color: '#697386' }}>
                    Loading recent cleanings...
                  </TableCell>
                </TableRow>
              ) : recentBookings.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 4, color: '#697386' }}>
                    No bookings registered in the system.
                  </TableCell>
                </TableRow>
              ) : (
                recentBookings.map((row) => (
                  <TableRow key={row.id} sx={{ '&:hover': { bgcolor: '#f6f9fc' } }}>
                    <TableCell sx={{ fontWeight: 600, color: '#0A2540', fontSize: '0.82rem' }}>
                      #{String(row.id || '').slice(0, 8)}
                    </TableCell>
                    <TableCell sx={{ fontWeight: 500 }}>
                      {row.customer?.full_name || 'Anonymous User'}
                    </TableCell>
                    <TableCell sx={{ fontWeight: 500 }}>{row.service?.name || 'Cleaning Service'}</TableCell>
                    <TableCell sx={{ fontSize: '0.85rem' }}>
                      {new Date(row.booking_date).toLocaleDateString()} at {row.booking_time}
                    </TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#0A2540' }}>
                      ${parseFloat(row.total_price).toFixed(2)}
                    </TableCell>
                    <TableCell>
                      <span className={`status-badge ${row.status}`}>
                        {row.status}
                      </span>
                    </TableCell>
                    <TableCell align="right" sx={{ pr: 3 }}>
                      <Button
                        size="small"
                        onClick={() => navigate('/bookings', { state: { highlightBookingId: row.id } })}
                        sx={{
                          textTransform: 'none',
                          color: '#635bff',
                          fontWeight: 600,
                          '&:hover': { bgcolor: 'rgba(99,91,255,0.04)' }
                        }}
                      >
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
