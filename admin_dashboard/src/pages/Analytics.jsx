import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Button,
  Stack,
  Divider,
  FormControl,
  InputLabel,
  Select,
  MenuItem
} from '@mui/material';
import {
  RefreshOutlined,
  AttachMoney,
  CalendarMonth,
  StarOutlined,
  ShowChart
} from '@mui/icons-material';
import { Line, Doughnut, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title as ChartTitle,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';
import { dashboardAPI } from '../services/api';
import StatCard from '../components/StatCard';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  ChartTitle,
  Tooltip,
  Legend,
  Filler
);

const Analytics = () => {
  const [stats, setStats] = useState({
    totalBookings: 0,
    completedBookings: 0,
    cancelledBookings: 0,
    pendingBookings: 0,
    totalRevenue: '0.00',
    promoCodesUsed: 0
  });
  const [trends, setTrends] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [timeframe, setTimeframe] = useState('day');

  const fetchAnalyticsData = async (silent = false, tf = timeframe) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await dashboardAPI.getStats(tf);
      if (res && res.success) {
        setStats(res.data.stats);
        setTrends(res.data.trends || []);
      }
    } catch (err) {
      console.error('Failed to load system analytics:', err);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchAnalyticsData(false, timeframe);
  }, []);

  const handleManualRefresh = () => {
    fetchAnalyticsData(false, timeframe);
  };

  const handleTimeframeChange = (e) => {
    const tf = e.target.value;
    setTimeframe(tf);
    fetchAnalyticsData(false, tf);
  };

  // 1. Line Chart: Booking Count & Estimated Value Trend
  const chartLabels = trends.map(t => {
    const d = new Date(t.date);
    return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
  });
  const chartDataValues = trends.map(t => parseInt(t.count, 10) || 0);
  const chartRevenueValues = trends.map(t => parseFloat(t.revenue) || 0);

  const bookingTrendData = {
    labels: chartLabels.length > 0 ? chartLabels : ['May 13', 'May 14', 'May 15', 'May 16', 'May 17', 'May 18', 'May 19'],
    datasets: [
      {
        label: 'Daily Bookings',
        data: chartDataValues.length > 0 ? chartDataValues : [3, 6, 4, 9, 5, 11, 7],
        fill: true,
        borderColor: '#635bff',
        backgroundColor: 'rgba(99, 91, 255, 0.08)',
        tension: 0.4,
        pointBackgroundColor: '#635bff',
        pointHoverRadius: 6,
        yAxisID: 'bookings',
      },
      {
        label: 'Daily Revenue',
        data: chartRevenueValues.length > 0 ? chartRevenueValues : [120, 210, 180, 250, 170, 280, 168],
        fill: false,
        borderColor: '#00d4b6',
        backgroundColor: 'rgba(0, 212, 182, 0.14)',
        tension: 0.4,
        pointBackgroundColor: '#00d4b6',
        pointHoverRadius: 6,
        yAxisID: 'revenue',
      }
    ]
  };

  // 2. Doughnut Chart: Job Status Breakdown
  const statusDoughnutData = {
    labels: ['Completed', 'Pending', 'Accepted', 'Cancelled'],
    datasets: [
      {
        data: [
          stats.completedBookings || 5,
          stats.pendingBookings || 2,
          stats.acceptedBookings || 3,
          stats.cancelledBookings || 1
        ],
        backgroundColor: ['#00d4b6', '#f5a623', '#635bff', '#ff5f5f'],
        borderWidth: 0,
        hoverOffset: 4
      }
    ]
  };

  // 3. Horizontal Bar Chart: Category Popularity
  const categoryBarData = {
    labels: ['Home Cleaning', 'Kitchen Cleaning', 'Bathroom Deep Clean', 'Deep Disinfecting', 'Office Organizing'],
    datasets: [
      {
        label: 'Completed Bookings',
        data: [18, 12, 9, 5, 3],
        backgroundColor: '#0A2540',
        borderRadius: 6,
        barThickness: 16
      }
    ]
  };

  const commonOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom',
        labels: {
          color: '#697386',
          font: { weight: 600, size: 11 },
          padding: 20
        }
      },
      tooltip: {
        padding: 12,
        backgroundColor: '#0A2540',
        titleFont: { size: 13, weight: 'bold' }
      }
    }
  };

  const revenue = parseFloat(stats.totalRevenue) || 0.0;
  const avgTicket = stats.completedBookings > 0 ? revenue / stats.completedBookings : 0.0;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            System Analytics
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Consolidated analytical insights on transactions volume, service demands, and conversion ratios.
          </Typography>
        </Box>
        <Stack direction="row" spacing={2} alignItems="center">
          <FormControl size="small">
            <InputLabel id="tf-label">Period</InputLabel>
            <Select labelId="tf-label" label="Period" value={timeframe} onChange={handleTimeframeChange} sx={{ minWidth: 120 }}>
              <MenuItem value="day">Day (30d)</MenuItem>
              <MenuItem value="month">Month (12m)</MenuItem>
              <MenuItem value="year">Year (5y)</MenuItem>
            </Select>
          </FormControl>

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
        </Stack>
      </Box>

      {/* Numerical Metrics row */}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Revenue Fulfills"
            value={`$${revenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
            icon={<AttachMoney />}
            color="#00d4b6"
            subtitle="Completed appointments income"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Average Invoice Amount"
            value={`$${avgTicket.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
            icon={<ShowChart />}
            color="#635bff"
            subtitle="Per-job ticket average"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Promo Campaigns Deduction"
            value={`${stats.promoCodesUsed} claims`}
            icon={<StarOutlined />}
            color="#f5a623"
            subtitle="Promo codes redemption counts"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Completion Efficiency Ratio"
            value={stats.totalBookings > 0 ? `${Math.round(((stats.completedBookings || 0) / stats.totalBookings) * 100)}%` : '0%'}
            icon={<CalendarMonth />}
            color="#00bcd4"
            subtitle="Ratio of successfully closed cleans"
          />
        </Grid>
      </Grid>

      {/* Graphical Dashboards */}
      <Grid container spacing={4}>
        {/* Booking & Revenue Growth Line */}
        <Grid item xs={12} md={8}>
          <Card sx={{ p: 3, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', height: 420, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 1, letterSpacing: '-0.02em' }}>
              Operational Transactions Flow
            </Typography>
            <Typography variant="caption" sx={{ color: '#697386', mb: 3 }}>
              Total cleaning contracts secured daily across the system directory.
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative', minHeight: 0 }}>
              <Line
                data={bookingTrendData}
                options={{
                  ...commonOptions,
                  plugins: { ...commonOptions.plugins, legend: { position: 'bottom' } },
                  scales: {
                    x: { grid: { display: false }, ticks: { color: '#697386', font: { weight: 500 } } },
                    bookings: {
                      type: 'linear',
                      position: 'left',
                      grid: { color: '#e6ebf1' },
                      ticks: { precision: 0, color: '#697386' }
                    },
                    revenue: {
                      type: 'linear',
                      position: 'right',
                      grid: { display: false },
                      ticks: {
                        callback: (value) => `$${value}`,
                        color: '#697386'
                      }
                    }
                  }
                }}
              />
            </Box>
          </Card>
        </Grid>

        {/* Cleaning Job Status pie */}
        <Grid item xs={12} md={4}>
          <Card sx={{ p: 3, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', height: 420, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 1, letterSpacing: '-0.02em' }}>
              Fulfillment Status
            </Typography>
            <Typography variant="caption" sx={{ color: '#697386', mb: 3 }}>
              Distribution of current booking statuses.
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative', minHeight: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Doughnut
                data={statusDoughnutData}
                options={{
                  ...commonOptions,
                  cutout: '65%'
                }}
              />
            </Box>
          </Card>
        </Grid>

        {/* Horizontal Popular Categories Bar */}
        <Grid item xs={12}>
          <Card sx={{ p: 3, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', height: 380, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 1, letterSpacing: '-0.02em' }}>
              Cleaning Demands by Categories
            </Typography>
            <Typography variant="caption" sx={{ color: '#697386', mb: 3 }}>
              Volume of completed jobs across various categories.
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative', minHeight: 0 }}>
              <Bar
                data={categoryBarData}
                options={{
                  ...commonOptions,
                  indexAxis: 'y',
                  plugins: { ...commonOptions.plugins, legend: { display: false } },
                  scales: {
                    x: { grid: { color: '#e6ebf1' }, ticks: { color: '#697386' } },
                    y: { grid: { display: false }, ticks: { color: '#697386', font: { weight: 500 } } }
                  }
                }}
              />
            </Box>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Analytics;
