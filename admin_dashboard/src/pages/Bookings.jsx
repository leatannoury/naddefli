/**
 * NADDEFLI — Bookings.jsx
 * Layer: Admin — Page
 * Purpose: All bookings list with date/status filters; accept, cancel, complete actions.
 * Connects to: /api/admin/bookings
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Card,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Tabs,
  Tab,
  TextField,
  InputAdornment,
  IconButton,
  TablePagination,
  Stack,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  Select,
  MenuItem,
  InputLabel,
  TableSortLabel
} from '@mui/material';
import {
  Search,
  RefreshOutlined,
  FilterList,
  CalendarMonth,
  Person,
  PaymentsOutlined
} from '@mui/icons-material';
import { bookingsAPI } from '../services/api';
import BookingDetails from '../components/BookingDetails';
import DateFilterBar, { todayStr } from '../components/DateFilterBar';
import { getBookingServiceLabel } from '../utils/bookingDisplay';
import { useLocation } from 'react-router-dom';

const Bookings = () => {
  const location = useLocation();
  const highlightBookingId = location.state?.highlightBookingId || null;
  const initialFilterTab = location.state?.initialTab || null;
  const routeFilterMode = location.state?.filterMode;
  const routeStartDate = location.state?.startDate;
  const routeEndDate = location.state?.endDate;

  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filterMode, setFilterMode] = useState(routeFilterMode || 'all');
  const [startDate, setStartDate] = useState(routeStartDate || todayStr());
  const [endDate, setEndDate] = useState(routeEndDate || todayStr());

  // Filter states
  const [tabValue, setTabValue] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortField, setSortField] = useState('newest');
  
  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Booking details modal
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [detailsOpen, setDetailsOpen] = useState(false);

  // Cancellation dialog
  const [cancelOpen, setCancelOpen] = useState(false);
  const [cancelBookingId, setCancelBookingId] = useState(null);
  const [cancelReason, setCancelReason] = useState('');

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

  const fetchBookings = useCallback(async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const bookingsRes = await bookingsAPI.getAll(buildParams());
      if (!bookingsRes) {
        setBookings([]);
      } else if (bookingsRes.success && Array.isArray(bookingsRes.data)) {
        setBookings(bookingsRes.data || []);
      } else if (Array.isArray(bookingsRes)) {
        setBookings(bookingsRes);
      } else if (bookingsRes.data && Array.isArray(bookingsRes.data)) {
        setBookings(bookingsRes.data);
      } else {
        setBookings([]);
      }
    } catch (error) {
      console.error('Failed to load bookings list:', error);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [buildParams]);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  useEffect(() => {
    const interval = setInterval(() => fetchBookings(true), 5000);
    return () => clearInterval(interval);
  }, [fetchBookings]);

  const handleFilterModeChange = (mode) => {
    setFilterMode(mode);
    setPage(0);
    if (mode === 'today') {
      const t = todayStr();
      setStartDate(t);
      setEndDate(t);
    }
  };

  // Highlight specific booking if routed from Dashboard
  useEffect(() => {
    if (highlightBookingId && bookings.length > 0) {
      const found = bookings.find(b => b.id === highlightBookingId);
      if (found) {
        setSelectedBooking(found);
        setDetailsOpen(true);
      }
    }
  }, [highlightBookingId, bookings]);

  useEffect(() => {
    if (initialFilterTab) {
      setTabValue(initialFilterTab);
      setPage(0);
    }
  }, [initialFilterTab]);

  const handleManualRefresh = () => {
    fetchBookings();
  };

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setPage(0);
  };

  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setPage(0);
  };

  const handleSortBy = (field) => {
    setSortField(field);
    setPage(0);
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Open booking detail modal
  const handleOpenDetails = (booking) => {
    setSelectedBooking(booking);
    setDetailsOpen(true);
  };

  // Approval flow
  const handleAccept = async (bookingId) => {
    try {
      const res = await bookingsAPI.accept(bookingId);
      if (res && res.success) {
        fetchBookings(true);
        setDetailsOpen(false);
        setSelectedBooking(null);
      }
    } catch (err) {
      console.error('Failed to approve booking:', err);
    }
  };

  // Cancellation flow
  const handleStartCancel = (bookingId) => {
    setCancelBookingId(bookingId);
    setCancelReason('');
    setCancelOpen(true);
  };

  const handleConfirmCancel = async () => {
    if (!cancelBookingId) return;
    try {
      const res = await bookingsAPI.cancel(cancelBookingId, cancelReason);
      if (res && res.success) {
        fetchBookings(true);
        setCancelOpen(false);
        setDetailsOpen(false);
        setSelectedBooking(null);
      }
    } catch (err) {
      console.error('Failed to cancel booking:', err);
    }
  };

  // Completion flow
  const handleComplete = async (bookingId) => {
    try {
      const res = await bookingsAPI.complete(bookingId);
      if (res && res.success) {
        fetchBookings(true);
        setDetailsOpen(false);
        setSelectedBooking(null);
      }
    } catch (err) {
      console.error('Failed to mark booking as completed:', err);
    }
  };

  // Filtering Logic
  const filteredBookings = bookings.filter((b) => {
    // 1. Status Filter Tab
    if (tabValue !== 'all' && b.status !== tabValue) {
      return false;
    }

    // 2. Search Query (id, customer name, customer email)
    if (searchQuery.trim() !== '') {
      const query = searchQuery.toLowerCase();
      const customerName = b.customer?.full_name?.toLowerCase() || '';
      const customerEmail = b.customer?.email?.toLowerCase() || '';
      const bookingId = b.id?.toLowerCase() || '';
      const bookingCity = b.city?.toLowerCase() || '';
      
      return (
        bookingId.includes(query) ||
        customerName.includes(query) ||
        customerEmail.includes(query) ||
        bookingCity.includes(query)
      );
    }

    return true;
  }).sort((a, b) => {
    if (sortField === 'price_asc') {
      return (a.total_price || 0) - (b.total_price || 0);
    }
    if (sortField === 'price_desc') {
      return (b.total_price || 0) - (a.total_price || 0);
    }
    if (sortField === 'customer_asc') {
      return (a.customer?.full_name || '').localeCompare(b.customer?.full_name || '');
    }
    if (sortField === 'customer_desc') {
      return (b.customer?.full_name || '').localeCompare(a.customer?.full_name || '');
    }
    if (sortField === 'date_asc') {
      return new Date(a.booking_date || 0) - new Date(b.booking_date || 0);
    }
    if (sortField === 'date_desc') {
      return new Date(b.booking_date || 0) - new Date(a.booking_date || 0);
    }
    // newest (default)
    return new Date(b.created_at || 0) - new Date(a.created_at || 0);
  });

  // Paginated bookings
  const paginatedBookings = filteredBookings.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Bookings Operations
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Monitor and review cleaning appointment requests, approve or reject bookings, and track payment status.
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
            px: 2.5,
            py: 1.2,
            borderRadius: '8px',
            bgcolor: '#fff',
            fontWeight: 600,
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

      <DateFilterBar
        filterMode={filterMode}
        startDate={startDate}
        endDate={endDate}
        onFilterModeChange={handleFilterModeChange}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
      />

      {/* Control Card with Tabs & Search */}
      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        {/* Search and Filters Bar */}
        <Box sx={{ p: 3, borderBottom: '1px solid #e6ebf1', display: 'flex', flexWrap: 'wrap', gap: 2, justifySelf: 'stretch', alignItems: 'center' }}>
          <TextField
            placeholder="Search by ID, name, email or city..."
            value={searchQuery}
            onChange={handleSearchChange}
            size="small"
            sx={{
              minWidth: { xs: '100%', sm: 350 },
              '& .MuiOutlinedInput-root': {
                borderRadius: '8px',
                bgcolor: '#f6f9fc',
                '& fieldset': { borderColor: '#e6ebf1' },
                '&:hover fieldset': { borderColor: '#cbd5e1' },
                '&.Mui-focused fieldset': { borderColor: '#635bff' }
              }
            }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search sx={{ color: '#a3b1c2' }} />
                </InputAdornment>
              )
            }}
          />

          <FormControl size="small" sx={{ minWidth: 160 }}>
            <InputLabel id="sort-bookings-label">Sort by</InputLabel>
            <Select
              labelId="sort-bookings-label"
              value={sortField}
              label="Sort by"
              onChange={(e) => setSortField(e.target.value)}
              sx={{ bgcolor: '#fff', borderRadius: '8px' }}
            >
              <MenuItem value="newest">Newest first</MenuItem>
              <MenuItem value="price_asc">Price low → high</MenuItem>
              <MenuItem value="price_desc">Price high → low</MenuItem>
              <MenuItem value="customer_asc">Customer A → Z</MenuItem>
              <MenuItem value="customer_desc">Customer Z → A</MenuItem>
              <MenuItem value="date_asc">Date earliest</MenuItem>
              <MenuItem value="date_desc">Date latest</MenuItem>
            </Select>
          </FormControl>

          <Tabs
            value={tabValue}
            onChange={handleTabChange}
            sx={{
              '& .MuiTabs-indicator': { bgcolor: '#635bff' },
              '& .MuiTab-root': {
                textTransform: 'none',
                fontWeight: 600,
                fontSize: '0.9rem',
                minWidth: 90,
                color: '#697386',
                '&.Mui-selected': { color: '#635bff' }
              }
            }}
          >
            <Tab label="All Bookings" value="all" />
            <Tab label="Pending" value="pending" />
            <Tab label="Accepted" value="accepted" />
            <Tab label="Completed" value="completed" />
            <Tab label="Cancelled" value="cancelled" />
          </Tabs>
        </Box>

        {/* Data Table */}
        <TableContainer sx={{ maxHeight: 600 }}>
          <Table stickyHeader sx={{ minWidth: 800 }}>
            <TableHead>
              <TableRow>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }} sortDirection={sortField === 'newest' ? 'desc' : false}>
              <TableSortLabel
                active={sortField === 'newest'}
                direction={sortField === 'newest' ? 'desc' : 'asc'}
                onClick={() => handleSortBy('newest')}
              >
                ID
              </TableSortLabel>
            </TableCell>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }} sortDirection={sortField === 'customer_asc' || sortField === 'customer_desc' ? (sortField === 'customer_asc' ? 'asc' : 'desc') : false}>
              <TableSortLabel
                active={sortField === 'customer_asc' || sortField === 'customer_desc'}
                direction={sortField === 'customer_asc' ? 'asc' : 'desc'}
                onClick={() => handleSortBy(sortField === 'customer_asc' ? 'customer_desc' : 'customer_asc')}
              >
                Customer
              </TableSortLabel>
            </TableCell>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>Service Details</TableCell>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>Approval</TableCell>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }} sortDirection={sortField === 'date_asc' || sortField === 'date_desc' ? (sortField === 'date_asc' ? 'asc' : 'desc') : false}>
              <TableSortLabel
                active={sortField === 'date_asc' || sortField === 'date_desc'}
                direction={sortField === 'date_asc' ? 'asc' : 'desc'}
                onClick={() => handleSortBy(sortField === 'date_asc' ? 'date_desc' : 'date_asc')}
              >
                Schedule
              </TableSortLabel>
            </TableCell>
            <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }} sortDirection={sortField === 'price_asc' || sortField === 'price_desc' ? (sortField === 'price_asc' ? 'asc' : 'desc') : false}>
              <TableSortLabel
                active={sortField === 'price_asc' || sortField === 'price_desc'}
                direction={sortField === 'price_asc' ? 'asc' : 'desc'}
                onClick={() => handleSortBy(sortField === 'price_asc' ? 'price_desc' : 'price_asc')}
              >
                Price
              </TableSortLabel>
            </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>Status</TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc', pr: 3 }}>Operations</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading && paginatedBookings.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center" sx={{ py: 6, color: '#697386' }}>
                    Loading appointments list...
                  </TableCell>
                </TableRow>
              ) : filteredBookings.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center" sx={{ py: 6, color: '#697386' }}>
                    No bookings found matching filters.
                  </TableCell>
                </TableRow>
              ) : (
                paginatedBookings.map((row) => (
                  <TableRow key={row.id} hover sx={{ cursor: 'pointer', '&:hover': { bgcolor: '#f8fafc' } }} onClick={() => handleOpenDetails(row)}>
                    <TableCell sx={{ fontWeight: 600, color: '#0A2540', fontSize: '0.82rem' }}>
                      #{String(row.id || '').slice(0, 8)}
                    </TableCell>
                    <TableCell sx={{ py: 1.5 }}>
                      <Stack spacing={0.2}>
                        <Typography variant="body2" sx={{ fontWeight: 600, color: '#0A2540' }}>
                          {row.customer?.full_name || 'Anonymous User'}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#697386' }}>
                          {row.customer?.email}
                        </Typography>
                      </Stack>
                    </TableCell>
                    <TableCell>
                      <Stack spacing={0.2}>
                        <Typography variant="body2" sx={{ fontWeight: 600, color: '#424e5e' }}>
                          {getBookingServiceLabel(row)}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#697386' }}>
                          {row.cleaning_type === 'deep' ? 'Deep' : 'Standard'} • {row.duration_hours}h
                        </Typography>
                      </Stack>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontWeight: 600, color: '#0A2540' }}>
                        {row.status === 'pending' ? 'Pending approval' : row.status === 'accepted' ? 'Approved' : 'Review status'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Stack spacing={0.2}>
                        <Typography variant="body2" sx={{ fontWeight: 500, color: '#424e5e' }}>
                          {new Date(row.booking_date).toLocaleDateString()}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#697386' }}>
                          {row.booking_time}
                        </Typography>
                      </Stack>
                    </TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#0A2540' }}>
                      ${parseFloat(row.total_price).toFixed(2)}
                    </TableCell>
                    <TableCell>
                      <span className={`status-badge ${row.status}`}>
                        {row.status}
                      </span>
                    </TableCell>
                    <TableCell align="right" sx={{ pr: 3 }} onClick={(e) => e.stopPropagation()}>
                      <Stack direction="row" spacing={1} justifyContent="flex-end">
                        <Button
                          variant="text"
                          size="small"
                          onClick={() => handleOpenDetails(row)}
                          sx={{ textTransform: 'none', fontWeight: 600, color: '#635bff' }}
                        >
                          View Details
                        </Button>
                        
                        {row.status === 'pending' && (
                          <Button
                            variant="contained"
                            size="small"
                            onClick={() => handleAccept(row.id)}
                            sx={{
                              bgcolor: '#635bff',
                              textTransform: 'none',
                              boxShadow: 'none',
                              fontWeight: 600,
                              height: 30,
                              '&:hover': { bgcolor: '#0A2540' }
                            }}
                          >
                            Accept
                          </Button>
                        )}

                        {row.status === 'accepted' && (
                          <Button
                            variant="contained"
                            size="small"
                            onClick={() => handleComplete(row.id)}
                            sx={{
                              bgcolor: '#00d4b6',
                              textTransform: 'none',
                              boxShadow: 'none',
                              fontWeight: 600,
                              height: 30,
                              '&:hover': { bgcolor: '#00bda2' }
                            }}
                          >
                            Complete
                          </Button>
                        )}
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <TablePagination
          rowsPerPageOptions={[5, 10, 25, 50]}
          component="div"
          count={filteredBookings.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          sx={{ borderTop: '1px solid #e6ebf1' }}
        />
      </Card>

      {/* Main Details Modal */}
      <BookingDetails
        open={detailsOpen}
        booking={selectedBooking}
        onClose={() => {
          setDetailsOpen(false);
          setSelectedBooking(null);
        }}
        onAccept={handleAccept}
        onCancel={handleStartCancel}
        onComplete={handleComplete}
      />


      {/* Booking Cancellation Dialog */}
      <Dialog open={cancelOpen} onClose={() => setCancelOpen(false)} fullWidth maxWidth="xs" PaperProps={{ sx: { borderRadius: '12px' } }}>
        <DialogTitle sx={{ fontWeight: 700, color: '#0A2540', pb: 1 }}>Reject/Cancel Booking</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ color: '#697386', mb: 3 }}>
            Are you sure you want to cancel this booking? This will notify the customer. Provide a brief reason below.
          </Typography>
          <TextField
            fullWidth
            label="Cancellation Reason"
            multiline
            rows={3}
            value={cancelReason}
            onChange={(e) => setCancelReason(e.target.value)}
            placeholder="e.g. Fully booked in that region, customer request, invalid address details..."
            sx={{
              '& .MuiOutlinedInput-root': {
                borderRadius: '8px',
              }
            }}
          />
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1 }}>
          <Button onClick={() => setCancelOpen(false)} sx={{ textTransform: 'none', color: '#697386' }}>
            Dismiss
          </Button>
          <Button
            onClick={handleConfirmCancel}
            variant="contained"
            color="error"
            sx={{ textTransform: 'none', boxShadow: 'none' }}
          >
            Confirm Cancellation
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Bookings;
