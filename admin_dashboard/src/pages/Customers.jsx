import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TableSortLabel,
  Paper,
  TextField,
  InputAdornment,
  TablePagination,
  Stack,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Chip,
  IconButton,
  FormControl,
  Select,
  MenuItem,
  InputLabel
} from '@mui/material';
import {
  Search,
  RefreshOutlined,
  PeopleAlt,
  Block,
  DeleteOutlined,
  LockOpen,
  MailOutlined,
  PhoneOutlined,
  Star
} from '@mui/icons-material';
import { customersAPI } from '../services/api';
import { getBookingServiceLabel } from '../utils/bookingDisplay';
import StatCard from '../components/StatCard';

const Customers = () => {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Search & Filter
  const [searchQuery, setSearchQuery] = useState('');
  const [sortField, setSortField] = useState('newest');
  const [createOpen, setCreateOpen] = useState(false);
  const [customerForm, setCustomerForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    password: '',
    loyalty_rewards_available: 0,
    is_blocked: false
  });
  
  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Detail Modal
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [detailOpen, setDetailOpen] = useState(false);

  // Action Confirmation Dialogs
  const [blockOpen, setBlockOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [targetCustomer, setTargetCustomer] = useState(null);

  const fetchCustomers = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await customersAPI.getAll();
      if (res && res.success) {
        setCustomers(res.data || []);
      }
    } catch (error) {
      console.error('Failed to fetch customers list:', error);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  const handleSortBy = (field) => {
    // toggle asc/desc for the same field
    if (field === 'name') {
      setSortField(prev => (prev === 'name_asc' ? 'name_desc' : 'name_asc'));
      return;
    }
    if (field === 'loyalty') {
      setSortField(prev => (prev === 'loyalty_asc' ? 'loyalty_desc' : 'loyalty_asc'));
      return;
    }
    if (field === 'bookings') {
      setSortField(prev => (prev === 'bookings_asc' ? 'bookings_desc' : 'bookings_asc'));
      return;
    }
    if (field === 'joined') {
      setSortField(prev => (prev === 'newest' ? 'oldest' : 'newest'));
      return;
    }
  };

  useEffect(() => {
    fetchCustomers();

    // Auto-refresh customers every 10 seconds
    const interval = setInterval(() => {
      fetchCustomers(true);
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  const handleManualRefresh = () => {
    fetchCustomers();
  };

  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setPage(0);
  };

  const handleSortChange = (event) => {
    setSortField(event.target.value);
    setPage(0);
  };

  const handleOpenCreate = () => {
    setCustomerForm({ full_name: '', email: '', phone: '', password: '', loyalty_rewards_available: 0, is_blocked: false });
    setCreateOpen(true);
  };

  const handleCreateInputChange = (key) => (event) => {
    const value = key === 'is_blocked' ? event.target.checked : event.target.value;
    setCustomerForm((prev) => ({ ...prev, [key]: value }));
  };

  const handleCreateCustomer = async () => {
    try {
      const payload = {
        ...customerForm,
        loyalty_rewards_available: parseInt(customerForm.loyalty_rewards_available, 10) || 0,
      };
      const res = await customersAPI.create(payload);
      if (res && res.success) {
        setCreateOpen(false);
        fetchCustomers(true);
      }
    } catch (err) {
      console.error('Failed to create customer:', err);
    }
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Open detailed customer information
  const handleOpenDetail = async (customer) => {
    try {
      const res = await customersAPI.getById(customer.id);
      if (res && res.success) {
        setSelectedCustomer(res.data);
        setDetailOpen(true);
      } else {
        setSelectedCustomer(customer);
        setDetailOpen(true);
      }
    } catch (err) {
      setSelectedCustomer(customer);
      setDetailOpen(true);
    }
  };

  // Trigger Block/Unblock Dialog
  const handleStartBlockToggle = (customer) => {
    setTargetCustomer(customer);
    setBlockOpen(true);
  };

  const handleConfirmBlockToggle = async () => {
    if (!targetCustomer) return;
    try {
      const nextBlockedState = !targetCustomer.is_blocked;
      const res = await customersAPI.block(targetCustomer.id, nextBlockedState);
      if (res && res.success) {
        fetchCustomers(true);
        setBlockOpen(false);
        setDetailOpen(false);
        setTargetCustomer(null);
      }
    } catch (err) {
      console.error('Failed to change customer block state:', err);
    }
  };

  // Trigger Delete Dialog
  const handleStartDelete = (customer) => {
    setTargetCustomer(customer);
    setDeleteOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (!targetCustomer) return;
    try {
      const res = await customersAPI.delete(targetCustomer.id);
      if (res && res.success) {
        fetchCustomers(true);
        setDeleteOpen(false);
        setDetailOpen(false);
        setTargetCustomer(null);
      }
    } catch (err) {
      console.error('Failed to delete customer:', err);
    }
  };

  // Filtering Logic
  const filteredCustomers = customers.filter((c) => {
    if (searchQuery.trim() !== '') {
      const query = searchQuery.toLowerCase();
      const name = c.full_name?.toLowerCase() || '';
      const email = c.email?.toLowerCase() || '';
      const phone = c.phone?.toLowerCase() || '';
      return name.includes(query) || email.includes(query) || phone.includes(query);
    }
    return true;
  }).sort((a, b) => {
    if (sortField === 'loyalty_desc') return (b.loyalty_rewards_available || 0) - (a.loyalty_rewards_available || 0);
    if (sortField === 'loyalty_asc') return (a.loyalty_rewards_available || 0) - (b.loyalty_rewards_available || 0);
    if (sortField === 'blocked_first') return (b.is_blocked ? 1 : 0) - (a.is_blocked ? 1 : 0);
    if (sortField === 'name_asc') return (a.full_name || '').localeCompare(b.full_name || '');
    if (sortField === 'name_desc') return (b.full_name || '').localeCompare(a.full_name || '');
    if (sortField === 'bookings_asc') return (a.bookings_count || 0) - (b.bookings_count || 0);
    if (sortField === 'bookings_desc') return (b.bookings_count || 0) - (a.bookings_count || 0);
    if (sortField === 'oldest') return new Date(a.created_at || a.updated_at || 0) - new Date(b.created_at || b.updated_at || 0);
    return new Date(b.created_at || b.updated_at || 0) - new Date(a.created_at || a.updated_at || 0);
  });

  const paginatedCustomers = filteredCustomers.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  // Statistics summaries
  const totalBlocked = customers.filter(c => c.is_blocked).length;
  const topLoyalty = customers.reduce((acc, c) => Math.max(acc, c.loyalty_rewards_available || 0), 0);

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Client Directory
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Manage platform customers, track loyalty rewards, review block lists, or delete accounts.
          </Typography>
        </Box>
        <Stack direction="row" spacing={1.5} flexWrap="wrap">
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
          <Button
            variant="contained"
            onClick={handleOpenCreate}
            sx={{
              textTransform: 'none',
              px: 2.5,
              py: 1.2,
              borderRadius: '8px',
              bgcolor: '#635bff',
              fontWeight: 600,
              boxShadow: 'none',
              '&:hover': { bgcolor: '#534bdb' }
            }}
          >
            Add Customer
          </Button>
        </Stack>
      </Box>

      {/* Customer Stat Cards */}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={4}>
          <StatCard
            title="Total Registered Customers"
            value={customers.length}
            icon={<PeopleAlt />}
            color="#635bff"
            subtitle="Platform users"
          />
        </Grid>
        <Grid item xs={12} sm={4}>
          <StatCard
            title="Deactivated Accounts"
            value={totalBlocked}
            icon={<Block />}
            color="#ff5f5f"
            subtitle="Suspended clients"
          />
        </Grid>
        <Grid item xs={12} sm={4}>
          <StatCard
            title="Highest Loyalty Balance"
            value={`${topLoyalty} rewards`}
            icon={<Star />}
            color="#f5a623"
            subtitle="Top customer rewards"
          />
        </Grid>
      </Grid>

      {/* Main Table Card */}
      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e6ebf1' }}>
          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems="center">
            <TextField
              placeholder="Search by full name, email address or phone..."
              value={searchQuery}
              onChange={handleSearchChange}
              size="small"
              sx={{
                minWidth: { xs: '100%', sm: 380 },
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
            <FormControl size="small" sx={{ minWidth: 180 }}>
              <InputLabel id="sort-customers-label">Sort by</InputLabel>
              <Select
                labelId="sort-customers-label"
                value={sortField}
                label="Sort by"
                onChange={handleSortChange}
                sx={{ bgcolor: '#fff', borderRadius: '8px' }}
              >
                <MenuItem value="newest">Newest first</MenuItem>
                <MenuItem value="loyalty_desc">Loyalty high → low</MenuItem>
                <MenuItem value="loyalty_asc">Loyalty low → high</MenuItem>
                <MenuItem value="blocked_first">Blocked users first</MenuItem>
              </Select>
            </FormControl>
          </Stack>
        </Box>

        <TableContainer>
          <Table sx={{ minWidth: 800 }}>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>
                  <TableSortLabel active={sortField.startsWith('name')} direction={sortField === 'name_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('name')}>
                    Full Name
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>Email Address</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>Phone Number</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>
                  <TableSortLabel active={sortField.includes('loyalty')} direction={sortField === 'loyalty_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('loyalty')}>
                    Available Rewards
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>
                  <TableSortLabel active={sortField.includes('bookings')} direction={sortField === 'bookings_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('bookings')}>
                    Cleanings booked
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc' }}>
                  <TableSortLabel active={sortField === 'newest' || sortField === 'oldest'} direction={sortField === 'oldest' ? 'asc' : 'desc'} onClick={() => handleSortBy('joined')}>
                    Status
                  </TableSortLabel>
                </TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#697386', bgcolor: '#f6f9fc', pr: 3 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading && paginatedCustomers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 6, color: '#697386' }}>
                    Loading customer directory...
                  </TableCell>
                </TableRow>
              ) : filteredCustomers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 6, color: '#697386' }}>
                    No customer matches found.
                  </TableCell>
                </TableRow>
              ) : (
                paginatedCustomers.map((row) => (
                  <TableRow key={row.id} hover sx={{ cursor: 'pointer', '&:hover': { bgcolor: '#f8fafc' } }} onClick={() => handleOpenDetail(row)}>
                    <TableCell sx={{ fontWeight: 600, color: '#0A2540' }}>
                      {row.full_name || 'Anonymous User'}
                    </TableCell>
                    <TableCell>{row.email}</TableCell>
                    <TableCell>{row.phone || 'No phone recorded'}</TableCell>
                    <TableCell sx={{ fontWeight: 600, color: '#f5a623' }}>
                      {row.loyalty_rewards_available || 0} rewards
                    </TableCell>
                    <TableCell sx={{ fontWeight: 600, color: '#0A2540' }}>
                      {row.bookings_count || 0} bookings
                    </TableCell>
                    <TableCell>
                      {row.is_blocked ? (
                        <Chip label="Blocked" size="small" sx={{ bgcolor: '#ff5f5f15', color: '#ff5f5f', fontWeight: 600 }} />
                      ) : (
                        <Chip label="Active" size="small" sx={{ bgcolor: '#00d4b615', color: '#00d4b6', fontWeight: 600 }} />
                      )}
                    </TableCell>
                    <TableCell align="right" sx={{ pr: 3 }} onClick={(e) => e.stopPropagation()}>
                      <Stack direction="row" spacing={1} justifyContent="flex-end">
                        <Button
                          variant="text"
                          size="small"
                          onClick={() => handleOpenDetail(row)}
                          sx={{ textTransform: 'none', fontWeight: 600, color: '#635bff' }}
                        >
                          Details
                        </Button>
                        <IconButton
                          size="small"
                          color={row.is_blocked ? 'success' : 'warning'}
                          onClick={() => handleStartBlockToggle(row)}
                          title={row.is_blocked ? 'Unblock user' : 'Block user'}
                        >
                          {row.is_blocked ? <LockOpen fontSize="small" /> : <Block fontSize="small" />}
                        </IconButton>
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleStartDelete(row)}
                          title="Delete customer"
                        >
                          <DeleteOutlined fontSize="small" />
                        </IconButton>
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
          count={filteredCustomers.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          sx={{ borderTop: '1px solid #e6ebf1' }}
        />
      </Card>

      <Dialog open={createOpen} onClose={() => setCreateOpen(false)} fullWidth maxWidth="sm" PaperProps={{ sx: { borderRadius: '16px' } }}>
        <DialogTitle sx={{ fontWeight: 800, color: '#0A2540' }}>Add New Customer</DialogTitle>
        <DialogContent sx={{ py: 2 }}>          
          <Stack spacing={2}>
            <TextField
              label="Full Name"
              value={customerForm.full_name}
              onChange={handleCreateInputChange('full_name')}
              fullWidth
              size="small"
            />
            <TextField
              label="Email Address"
              value={customerForm.email}
              onChange={handleCreateInputChange('email')}
              fullWidth
              size="small"
              type="email"
            />
            <TextField
              label="Phone Number"
              value={customerForm.phone}
              onChange={handleCreateInputChange('phone')}
              fullWidth
              size="small"
              type="tel"
            />
            <TextField
              label="Password"
              value={customerForm.password}
              onChange={handleCreateInputChange('password')}
              fullWidth
              size="small"
              type="password"
            />
            <TextField
              label="Available Rewards"
              value={customerForm.loyalty_rewards_available}
              onChange={handleCreateInputChange('loyalty_rewards_available')}
              fullWidth
              size="small"
              type="number"
              inputProps={{ min: 0 }}
            />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1.5 }}>
          <Button onClick={() => setCreateOpen(false)} variant="outlined" sx={{ textTransform: 'none', borderColor: '#e6ebf1', color: '#0A2540' }}>
            Cancel
          </Button>
          <Button onClick={handleCreateCustomer} variant="contained" sx={{ textTransform: 'none', boxShadow: 'none', bgcolor: '#635bff', '&:hover': { bgcolor: '#534bdb' } }}>
            Save Customer
          </Button>
        </DialogActions>
      </Dialog>

      {/* Customer Detail Dialog */}
      <Dialog open={detailOpen} onClose={() => setDetailOpen(false)} fullWidth maxWidth="sm" PaperProps={{ sx: { borderRadius: '16px', p: 1 } }}>
        <DialogTitle sx={{ fontWeight: 800, color: '#0A2540', pb: 1 }}>
          Client Profile Details
        </DialogTitle>
        <DialogContent sx={{ py: 2 }}>
          {selectedCustomer && (
            <Stack spacing={3.5}>
              <Box sx={{ p: 2.5, bgcolor: '#f6f9fc', border: '1px solid #e6ebf1', borderRadius: '12px' }}>
                <Typography variant="h6" sx={{ fontWeight: 800, color: '#0A2540', mb: 1 }}>
                  {selectedCustomer.full_name}
                </Typography>
                <Stack spacing={1} sx={{ mt: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <MailOutlined sx={{ color: '#a3b1c2', fontSize: 18 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', fontWeight: 500 }}>
                      {selectedCustomer.email}
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <PhoneOutlined sx={{ color: '#a3b1c2', fontSize: 18 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', fontWeight: 500 }}>
                      {selectedCustomer.phone || 'No phone recorded'}
                    </Typography>
                  </Box>
                </Stack>
              </Box>

              {/* Loyalty & Operations Stat Summary */}
              <Grid container spacing={2}>
                <Grid item xs={6}>
                  <Box sx={{ border: '1px solid #e6ebf1', p: 2, borderRadius: '8px', textAlign: 'center' }}>
                    <Typography variant="caption" sx={{ color: '#697386', fontWeight: 600 }}>AVAILABLE REWARDS</Typography>
                    <Typography variant="h5" sx={{ fontWeight: 800, color: '#f5a623', mt: 0.5 }}>
                      {selectedCustomer.loyalty_rewards_available || 0}
                    </Typography>
                  </Box>
                </Grid>
                <Grid item xs={6}>
                  <Box sx={{ border: '1px solid #e6ebf1', p: 2, borderRadius: '8px', textAlign: 'center' }}>
                    <Typography variant="caption" sx={{ color: '#697386', fontWeight: 600 }}>TOTAL APPOINTMENTS</Typography>
                    <Typography variant="h5" sx={{ fontWeight: 800, color: '#0A2540', mt: 0.5 }}>
                      {selectedCustomer.bookings?.length ?? selectedCustomer.bookings_count ?? 0}
                    </Typography>
                  </Box>
                </Grid>
              </Grid>

              {/* Booking History or Address List if exists */}
              {selectedCustomer.addresses && selectedCustomer.addresses.length > 0 && (
                <Box>
                  <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                    SAVED ADDRESSES
                  </Typography>
                  <Stack spacing={1}>
                    {selectedCustomer.addresses.map((addr, idx) => (
                      <Box key={idx} sx={{ p: 1.5, border: '1px solid #e6ebf1', borderRadius: '8px', bgcolor: '#fff' }}>
                        <Typography variant="body2" sx={{ color: '#0A2540', fontWeight: 600 }}>
                          {addr.street || addr.address_line}, {addr.city}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#697386' }}>
                          Type: {addr.type || 'home'}
                        </Typography>
                      </Box>
                    ))}
                  </Stack>
                </Box>
              )}

              {selectedCustomer.bookings && selectedCustomer.bookings.length > 0 && (
                <Box>
                  <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                    RECENT BOOKINGS
                  </Typography>
                  <Stack spacing={1}>
                    {selectedCustomer.bookings.slice(0, 5).map((booking) => (
                      <Box key={booking.id} sx={{ p: 1.5, border: '1px solid #e6ebf1', borderRadius: '8px', bgcolor: '#fff' }}>
                        <Stack direction="row" justifyContent="space-between" alignItems="center">
                          <Typography variant="body2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                            {getBookingServiceLabel(booking)}
                          </Typography>
                          <Typography variant="caption" sx={{ color: '#697386' }}>
                            {new Date(booking.booking_date).toLocaleDateString()}
                          </Typography>
                        </Stack>
                        <Typography variant="body2" sx={{ color: '#424e5e', mt: 0.5 }}>
                          {booking.cleaning_type === 'deep' ? 'Deep cleaning' : 'Standard cleaning'} · ${parseFloat(booking.total_price || 0).toFixed(2)}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#635bff', fontWeight: 700, mt: 0.5, display: 'block' }}>
                          {booking.status?.charAt(0).toUpperCase() + booking.status?.slice(1)}
                        </Typography>
                      </Box>
                    ))}
                  </Stack>
                </Box>
              )}
            </Stack>
          )}
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1.5 }}>
          <Button onClick={() => setDetailOpen(false)} variant="outlined" sx={{ textTransform: 'none', borderColor: '#e6ebf1', color: '#0A2540' }}>
            Close Details
          </Button>
          {selectedCustomer && (
            <>
              <Button
                onClick={() => handleStartBlockToggle(selectedCustomer)}
                variant="outlined"
                color={selectedCustomer.is_blocked ? 'success' : 'warning'}
                sx={{ textTransform: 'none' }}
              >
                {selectedCustomer.is_blocked ? 'Activate Account' : 'Deactivate Account'}
              </Button>
              <Button
                onClick={() => handleStartDelete(selectedCustomer)}
                variant="contained"
                color="error"
                sx={{ textTransform: 'none', boxShadow: 'none' }}
              >
                Delete Client
              </Button>
            </>
          )}
        </DialogActions>
      </Dialog>

      {/* Block Confirmation Dialog */}
      <Dialog open={blockOpen} onClose={() => setBlockOpen(false)} fullWidth maxWidth="xs" PaperProps={{ sx: { borderRadius: '12px' } }}>
        <DialogTitle sx={{ fontWeight: 700, color: '#0A2540', pb: 1 }}>
          {targetCustomer?.is_blocked ? 'Unblock customer account?' : 'Suspend customer account?'}
        </DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ color: '#697386' }}>
            {targetCustomer?.is_blocked
              ? `Are you sure you want to unblock ${targetCustomer?.full_name}? They will immediately be allowed to place new cleaning bookings and log in.`
              : `Are you sure you want to suspend/block ${targetCustomer?.full_name}? Suspended clients are rejected from logging in and placing new bookings.`
            }
          </Typography>
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1 }}>
          <Button onClick={() => setBlockOpen(false)} sx={{ textTransform: 'none', color: '#697386' }}>
            Dismiss
          </Button>
          <Button
            onClick={handleConfirmBlockToggle}
            variant="contained"
            color={targetCustomer?.is_blocked ? 'success' : 'warning'}
            sx={{ textTransform: 'none', boxShadow: 'none' }}
          >
            Confirm
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteOpen} onClose={() => setDeleteOpen(false)} fullWidth maxWidth="xs" PaperProps={{ sx: { borderRadius: '12px' } }}>
        <DialogTitle sx={{ fontWeight: 700, color: '#0A2540', pb: 1 }}>Delete customer profile?</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ color: '#697386' }}>
            Are you absolutely sure you want to permanently delete the profile of {targetCustomer?.full_name}?
            <br /><br />
            <strong>Warning:</strong> This operation is irreversible and deletes their historical bookings/addresses or anonymizes database linkages!
          </Typography>
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1 }}>
          <Button onClick={() => setDeleteOpen(false)} sx={{ textTransform: 'none', color: '#697386' }}>
            Cancel
          </Button>
          <Button
            onClick={handleConfirmDelete}
            variant="contained"
            color="error"
            sx={{ textTransform: 'none', boxShadow: 'none' }}
          >
            Confirm Delete
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Customers;
