/**
 * NADDEFLI — Analytics.jsx
 * Layer: Admin — Page
 * Purpose: Analytics charts and reports.
 * Connects to: Dashboard/analytics API data
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Button,
  Stack,
} from '@mui/material';
import {
  RefreshOutlined,
  AttachMoney,
  CalendarMonth,
  CheckCircleOutlined,
  ShowChart,
} from '@mui/icons-material';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title as ChartTitle,
  Tooltip,
  Legend,
} from 'chart.js';
import { dashboardAPI } from '../services/api';
import StatCard from '../components/StatCard';
import DateFilterBar, { todayStr } from '../components/DateFilterBar';

ChartJS.register(CategoryScale, LinearScale, BarElement, ChartTitle, Tooltip, Legend);

const Analytics = () => {
  const [stats, setStats] = useState({
    totalBookings: 0,
    completedBookings: 0,
    cancelledBookings: 0,
    pendingBookings: 0,
    totalRevenue: '0.00',
    promoCodesUsed: 0,
  });
  const [trends, setTrends] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filterMode, setFilterMode] = useState('today');
  const [startDate, setStartDate] = useState(todayStr());
  const [endDate, setEndDate] = useState(todayStr());
  const [timeframe, setTimeframe] = useState('day');

  const buildParams = useCallback(() => {
    const params = { filterMode, dateField: 'booking_date', timeframe };
    if (filterMode === 'today') {
      const t = todayStr();
      params.startDate = t;
      params.endDate = t;
    } else if (filterMode === 'range') {
      params.startDate = startDate;
      params.endDate = endDate;
    }
    return params;
  }, [filterMode, startDate, endDate, timeframe]);

  const fetchAnalyticsData = useCallback(async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await dashboardAPI.getStats(buildParams());
      if (res && res.success) {
        setStats(res.data.stats);
        setTrends(res.data.trends || []);
      }
    } catch (err) {
      console.error('Failed to load analytics:', err);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [buildParams]);

  useEffect(() => {
    fetchAnalyticsData();
  }, [fetchAnalyticsData]);

  const handleFilterModeChange = (mode) => {
    setFilterMode(mode);
    if (mode === 'today') {
      const t = todayStr();
      setStartDate(t);
      setEndDate(t);
    }
  };

  const chartLabels = trends.map((t) => {
    const d = new Date(t.date);
    if (timeframe === 'month') return d.toLocaleDateString(undefined, { month: 'short', year: 'numeric' });
    if (timeframe === 'year') return d.getFullYear().toString();
    return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
  });
  const chartBookingValues = trends.map((t) => parseInt(t.count, 10) || 0);
  const chartRevenueValues = trends.map((t) => parseFloat(t.revenue) || 0);

  const barData = {
    labels: chartLabels.length > 0 ? chartLabels : ['No data'],
    datasets: [
      {
        label: 'Bookings',
        data: chartBookingValues.length > 0 ? chartBookingValues : [0],
        backgroundColor: 'rgba(99, 91, 255, 0.75)',
        borderRadius: 6,
        yAxisID: 'y',
      },
      {
        label: 'Revenue ($)',
        data: chartRevenueValues.length > 0 ? chartRevenueValues : [0],
        backgroundColor: 'rgba(0, 212, 182, 0.75)',
        borderRadius: 6,
        yAxisID: 'y1',
      },
    ],
  };

  const revenue = parseFloat(stats.totalRevenue) || 0;
  const avgTicket = stats.completedBookings > 0 ? revenue / stats.completedBookings : 0;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Revenue & Booking Analytics
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Bar chart of bookings and revenue by schedule date.
          </Typography>
        </Box>
        <Button
          variant="outlined"
          startIcon={<RefreshOutlined />}
          onClick={() => fetchAnalyticsData()}
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
        timeframe={timeframe}
        showTimeframe
        onFilterModeChange={handleFilterModeChange}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
        onTimeframeChange={setTimeframe}
      />

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Revenue" value={`$${revenue.toLocaleString(undefined, { minimumFractionDigits: 2 })}`} icon={<AttachMoney />} color="#00d4b6" subtitle="Completed jobs in period" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Bookings" value={stats.totalBookings} icon={<CalendarMonth />} color="#635bff" subtitle="Scheduled in period" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Completed" value={stats.completedBookings} icon={<CheckCircleOutlined />} color="#00d4b6" subtitle="Fulfilled jobs" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Avg. ticket" value={`$${avgTicket.toFixed(2)}`} icon={<ShowChart />} color="#635bff" subtitle="Per completed job" />
        </Grid>
      </Grid>

      <Card sx={{ p: 3, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none' }}>
        <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 0.5 }}>
          Bookings & Revenue
        </Typography>
        <Typography variant="caption" sx={{ color: '#697386', display: 'block', mb: 2 }}>
          Purple bars = number of cleanings booked · Teal bars = revenue from completed jobs
        </Typography>
        <Box sx={{ height: 400 }}>
          {!loading && (
            <Bar
              data={barData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                  legend: { position: 'bottom', labels: { font: { weight: 600 } } },
                  tooltip: { padding: 12, backgroundColor: '#0A2540' },
                },
                scales: {
                  x: { grid: { display: false }, ticks: { color: '#697386' } },
                  y: {
                    type: 'linear',
                    position: 'left',
                    title: { display: true, text: 'Bookings' },
                    ticks: { precision: 0, color: '#635bff' },
                    grid: { color: '#e6ebf1' },
                  },
                  y1: {
                    type: 'linear',
                    position: 'right',
                    title: { display: true, text: 'Revenue ($)' },
                    grid: { drawOnChartArea: false },
                    ticks: { callback: (v) => `$${v}`, color: '#00d4b6' },
                  },
                },
              }}
            />
          )}
        </Box>
      </Card>
    </Box>
  );
};

export default Analytics;
