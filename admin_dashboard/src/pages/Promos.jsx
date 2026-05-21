import React, { useState, useEffect } from 'react';
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
  TableSortLabel,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Switch,
  FormControlLabel,
  InputAdornment,
  TablePagination,
  Stack,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  IconButton,
  Grid
} from '@mui/material';
import {
  Add,
  Search,
  RefreshOutlined,
  ConfirmationNumberOutlined,
  EditOutlined,
  DeleteOutlined,
  AttachMoney,
  Percent,
  CalendarMonth
} from '@mui/icons-material';
import { promosAPI } from '../services/api';

const Promos = () => {
  const [promos, setPromos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Search
  const [searchQuery, setSearchQuery] = useState('');

  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [sortField, setSortField] = useState('code_asc');

  // Dialog State
  const [dialogOpen, setDialogOpen] = useState(false);
  const [selectedPromo, setSelectedPromo] = useState(null);
  const [isEditMode, setIsEditMode] = useState(false);

  // Form Fields
  const [formCode, setFormCode] = useState('');
  const [formType, setFormType] = useState('percentage');
  const [formValue, setFormValue] = useState('');
  const [formConditions, setFormConditions] = useState('');
  const [formExpiresAt, setFormExpiresAt] = useState('');
  const [formIsActive, setFormIsActive] = useState(true);

  // Delete dialog
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [targetPromo, setTargetPromo] = useState(null);

  const fetchPromos = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await promosAPI.getAll();
      if (res && res.success) {
        setPromos(res.data || []);
      }
    } catch (error) {
      console.error('Failed to load campaigns/coupons list:', error);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchPromos();
  }, []);

  const handleManualRefresh = () => {
    fetchPromos();
  };

  const resetForm = () => {
    setFormCode('');
    setFormType('percentage');
    setFormValue('');
    setFormConditions('');
    setFormExpiresAt('');
    setFormIsActive(true);
    setSelectedPromo(null);
  };

  const handleOpenCreate = () => {
    resetForm();
    setIsEditMode(false);
    setDialogOpen(true);
  };

  const handleOpenEdit = (promo) => {
    setSelectedPromo(promo);
    setFormCode(promo.code || '');
    setFormType(promo.type || 'percentage');
    setFormValue(promo.value ? parseFloat(promo.value).toString() : '');
    setFormConditions(promo.conditions || '');
    setFormExpiresAt(promo.expires_at ? promo.expires_at.split('T')[0] : '');
    setFormIsActive(promo.is_active !== false);
    setIsEditMode(true);
    setDialogOpen(true);
  };

  const handleSavePromo = async () => {
    if (!formCode || !formValue) {
      alert('Please enter a promo code and value.');
      return;
    }

    const promoData = {
      code: formCode.toUpperCase().replace(/\s+/g, ''),
      type: formType,
      value: parseFloat(formValue),
      conditions: formConditions || null,
      expires_at: formExpiresAt ? new Date(formExpiresAt).toISOString() : null,
      is_active: formIsActive
    };

    try {
      let res;
      if (isEditMode && selectedPromo) {
        res = await promosAPI.update(selectedPromo.id, promoData);
      } else {
        res = await promosAPI.create(promoData);
      }

      if (res && res.success) {
        fetchPromos(true);
        setDialogOpen(false);
        resetForm();
      }
    } catch (err) {
      console.error('Failed to save promo code:', err);
    }
  };

  const handleToggleActive = async (promo) => {
    try {
      const nextActiveState = !promo.is_active;
      const res = await promosAPI.update(promo.id, {
        code: promo.code,
        type: promo.type,
        value: promo.value,
        is_active: nextActiveState
      });
      if (res && res.success) {
        setPromos(prev => prev.map(p => p.id === promo.id ? { ...p, is_active: nextActiveState } : p));
      }
    } catch (err) {
      console.error('Failed to toggle active status of promo:', err);
    }
  };

  const handleStartDelete = (promo) => {
    setTargetPromo(promo);
    setDeleteOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (!targetPromo) return;
    try {
      const res = await promosAPI.delete(targetPromo.id);
      if (res && res.success) {
        fetchPromos(true);
        setDeleteOpen(false);
        setTargetPromo(null);
      }
    } catch (err) {
      console.error('Failed to delete coupon:', err);
    }
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleSortBy = (field) => {
    if (field === 'code') setSortField(prev => (prev === 'code_asc' ? 'code_desc' : 'code_asc'));
    if (field === 'value') setSortField(prev => (prev === 'value_asc' ? 'value_desc' : 'value_asc'));
    if (field === 'expires') setSortField(prev => (prev === 'expires_asc' ? 'expires_desc' : 'expires_asc'));
  };

  const filteredPromos = promos.filter((p) => {
    if (searchQuery.trim() !== '') {
      return p.code?.toLowerCase().includes(searchQuery.toLowerCase());
    }
    return true;
  });

  // Apply sorting
  filteredPromos.sort((a, b) => {
    if (sortField === 'code_asc') return (a.code || '').localeCompare(b.code || '');
    if (sortField === 'code_desc') return (b.code || '').localeCompare(a.code || '');
    if (sortField === 'value_asc') return (a.value || 0) - (b.value || 0);
    if (sortField === 'value_desc') return (b.value || 0) - (a.value || 0);
    if (sortField === 'expires_asc') return new Date(a.expires_at || 0) - new Date(b.expires_at || 0);
    if (sortField === 'expires_desc') return new Date(b.expires_at || 0) - new Date(a.expires_at || 0);
    return 0;
  });

  const getConditionLabel = (condition) => {
    const labels = {
      'minimum_order_50': 'Min. $50 order',
      'minimum_order_100': 'Min. $100 order',
      'deep_cleaning_only': 'Deep cleaning only',
      'standard_cleaning_only': 'Standard cleaning only',
      'first_time_customers': 'First-time users',
      'weekend_only': 'Weekends only',
      'recurring_customers': 'Returning customers',
      'new_customers': 'New customers only'
    };
    return labels[condition] || 'No restrictions';
  };

  const paginatedPromos = filteredPromos.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Promo Campaigns
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Create discount offers, set loyalty point multipliers, configure constraints, and inspect active codes.
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
              boxShadow: '0 2px 4px rgba(0,0,0,0.01)',
              '&:hover': {
                borderColor: '#635bff',
                bgcolor: '#f6f9fc'
              }
            }}
          >
            {isRefreshing ? 'Refreshing...' : 'Refresh'}
          </Button>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleOpenCreate}
            sx={{
              bgcolor: '#635bff',
              textTransform: 'none',
              boxShadow: 'none',
              px: 2.5,
              py: 1.2,
              borderRadius: '8px',
              fontWeight: 600,
              '&:hover': { bgcolor: '#0A2540' }
            }}
          >
            Add Promo Code
          </Button>
        </Stack>
      </Box>

      {/* Control Card */}
      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', overflow: 'hidden' }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e6ebf1' }}>
          <TextField
            placeholder="Search active promo codes..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
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
        </Box>

        <TableContainer>
          <Table sx={{ minWidth: 800 }}>
            <TableHead sx={{ bgcolor: '#f6f9fc' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>
                  <TableSortLabel active={sortField.startsWith('code')} direction={sortField === 'code_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('code')}>
                    Promo Code
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Discount Type</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>
                  <TableSortLabel active={sortField.startsWith('value')} direction={sortField === 'value_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('value')}>
                    Discount Value
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>
                  <TableSortLabel active={sortField.startsWith('expires')} direction={sortField === 'expires_desc' ? 'desc' : 'asc'} onClick={() => handleSortBy('expires')}>
                    Validity / Expiration
                  </TableSortLabel>
                </TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Conditions</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#697386' }}>Status</TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#697386', pr: 3 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading && paginatedPromos.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 6, color: '#697386' }}>
                    Loading campaigns ledger...
                  </TableCell>
                </TableRow>
              ) : filteredPromos.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 6, color: '#697386' }}>
                    No promo codes registered. Click "Add Promo Code" to launch a campaign.
                  </TableCell>
                </TableRow>
              ) : (
                paginatedPromos.map((row) => {
                  const isExpired = row.expires_at && new Date(row.expires_at) < new Date();
                  return (
                    <TableRow key={row.id} hover sx={{ cursor: 'pointer', '&:hover': { bgcolor: '#f8fafc' } }} onClick={() => handleOpenEdit(row)}>
                      <TableCell sx={{ fontWeight: 800, color: '#635bff', letterSpacing: '0.05em' }}>
                        {row.code}
                      </TableCell>
                      <TableCell sx={{ textTransform: 'capitalize', fontWeight: 600 }}>
                        {row.type === 'percentage' ? 'Percentage' : row.type === 'fixed' ? 'Fixed Amount' : 'Add-on Reward'}
                      </TableCell>
                      <TableCell sx={{ fontWeight: 700, color: '#0A2540' }}>
                        {row.type === 'percentage' ? `${parseFloat(row.value)}%` : `$${parseFloat(row.value).toFixed(2)}`}
                      </TableCell>
                      <TableCell>
                        {row.expires_at ? (
                          <Stack direction="row" spacing={0.5} alignItems="center">
                            <CalendarMonth sx={{ fontSize: 16, color: isExpired ? '#ff5f5f' : '#697386' }} />
                            <Typography variant="body2" sx={{ color: isExpired ? '#ff5f5f' : '#0A2540', fontWeight: isExpired ? 600 : 500 }}>
                              {new Date(row.expires_at).toLocaleDateString()} {isExpired && '(Expired)'}
                            </Typography>
                          </Stack>
                        ) : (
                          <Typography variant="body2" sx={{ color: '#cbd5e1' }}>No limit</Typography>
                        )}
                      </TableCell>
                      <TableCell sx={{ fontSize: '0.85rem', color: '#697386', maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        <Chip
                          label={getConditionLabel(row.conditions)}
                          size="small"
                          sx={{ bgcolor: '#f6f9fc', color: '#697386', fontWeight: 600 }}
                        />
                      </TableCell>
                      <TableCell onClick={(e) => e.stopPropagation()}>
                        <FormControlLabel
                          control={
                            <Switch
                              size="small"
                              checked={row.is_active !== false && !isExpired}
                              disabled={isExpired}
                              onChange={() => handleToggleActive(row)}
                              sx={{
                                '& .MuiSwitch-switchBase.Mui-checked': { color: '#635bff' },
                                '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { bgcolor: '#635bff' }
                              }}
                            />
                          }
                          label={row.is_active ? 'Active' : 'Inactive'}
                          componentsProps={{ typography: { fontSize: '0.85rem', fontWeight: 600, color: '#697386' } }}
                        />
                      </TableCell>
                      <TableCell align="right" sx={{ pr: 3 }} onClick={(e) => e.stopPropagation()}>
                        <Stack direction="row" spacing={0.5} justifyContent="flex-end">
                          <IconButton size="small" onClick={() => handleOpenEdit(row)} sx={{ color: '#0A2540', '&:hover': { bgcolor: '#f6f9fc' } }}>
                            <EditOutlined fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleStartDelete(row)} sx={{ color: '#ff5f5f', '&:hover': { bgcolor: 'rgba(255, 95, 95, 0.05)' } }}>
                            <DeleteOutlined fontSize="small" />
                          </IconButton>
                        </Stack>
                      </TableCell>
                    </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <TablePagination
          rowsPerPageOptions={[5, 10, 25, 50]}
          component="div"
          count={filteredPromos.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          sx={{ borderTop: '1px solid #e6ebf1' }}
        />
      </Card>

      {/* Editor Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} fullWidth maxWidth="sm" PaperProps={{ sx: { borderRadius: '16px', p: 1 } }}>
        <DialogTitle sx={{ fontWeight: 800, color: '#0A2540', pb: 1 }}>
          {isEditMode ? 'Modify Promo Code' : 'Create Dynamic Promo Code'}
        </DialogTitle>
        <DialogContent sx={{ py: 2 }}>
          <Stack spacing={2.5} sx={{ mt: 1 }}>
            <TextField
              label="Promo Code String"
              fullWidth
              value={formCode}
              onChange={(e) => setFormCode(e.target.value.toUpperCase())}
              placeholder="e.g. SUMMER50"
              disabled={isEditMode}
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
            />

            <Grid container spacing={2.5}>
              <Grid item xs={6}>
                <FormControl fullWidth size="medium">
                  <InputLabel id="promo-type-label">Discount Type</InputLabel>
                  <Select
                    labelId="promo-type-label"
                    value={formType}
                    label="Discount Type"
                    onChange={(e) => setFormType(e.target.value)}
                    sx={{ borderRadius: '8px' }}
                  >
                    <MenuItem value="percentage">Percentage (%)</MenuItem>
                    <MenuItem value="fixed">Fixed Amount ($)</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={6}>
                <TextField
                  label="Discount Value"
                  fullWidth
                  type="number"
                  value={formValue}
                  onChange={(e) => setFormValue(e.target.value)}
                  placeholder="e.g. 15"
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        {formType === 'percentage' ? <Percent fontSize="small" /> : <AttachMoney fontSize="small" />}
                      </InputAdornment>
                    )
                  }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
                />
              </Grid>
            </Grid>

            <FormControl fullWidth size="medium">
              <InputLabel id="conditions-label">Campaign Conditions</InputLabel>
              <Select
                labelId="conditions-label"
                value={formConditions}
                label="Campaign Conditions"
                onChange={(e) => setFormConditions(e.target.value)}
                sx={{ borderRadius: '8px' }}
              >
                <MenuItem value="">No restrictions</MenuItem>
                <MenuItem value="minimum_order_50">Minimum order $50</MenuItem>
                <MenuItem value="minimum_order_100">Minimum order $100</MenuItem>
                <MenuItem value="deep_cleaning_only">Deep cleaning services only</MenuItem>
                <MenuItem value="standard_cleaning_only">Standard cleaning only</MenuItem>
                <MenuItem value="first_time_customers">First-time customers only</MenuItem>
                <MenuItem value="weekend_only">Weekends only</MenuItem>
                <MenuItem value="recurring_customers">Returning customers only</MenuItem>
                <MenuItem value="new_customers">New customers only</MenuItem>
              </Select>
            </FormControl>

            <TextField
              label="Expiration Date"
              fullWidth
              type="date"
              value={formExpiresAt}
              onChange={(e) => setFormExpiresAt(e.target.value)}
              InputLabelProps={{ shrink: true }}
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
            />

            <FormControlLabel
              control={
                <Switch
                  checked={formIsActive}
                  onChange={(e) => setFormIsActive(e.target.checked)}
                  sx={{
                    '& .MuiSwitch-switchBase.Mui-checked': { color: '#635bff' },
                    '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { bgcolor: '#635bff' }
                  }}
                />
              }
              label="Make active immediately"
              componentsProps={{ typography: { fontWeight: 600, color: '#424e5e' } }}
            />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1.5 }}>
          <Button onClick={() => setDialogOpen(false)} variant="outlined" sx={{ textTransform: 'none', borderColor: '#e6ebf1', color: '#0A2540' }}>
            Cancel
          </Button>
          <Button
            onClick={handleSavePromo}
            variant="contained"
            sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none', '&:hover': { bgcolor: '#0A2540' } }}
          >
            {isEditMode ? 'Update Campaign' : 'Launch Campaign'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete confirmation dialog */}
      <Dialog open={deleteOpen} onClose={() => setDeleteOpen(false)} fullWidth maxWidth="xs" PaperProps={{ sx: { borderRadius: '12px' } }}>
        <DialogTitle sx={{ fontWeight: 700, color: '#0A2540', pb: 1 }}>Delete Promo Campaign?</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ color: '#697386' }}>
            Are you sure you want to permanently delete promo campaign <strong>{targetPromo?.code}</strong>?
            <br /><br />
            Historical usage metrics in past bookings will be preserved, but the code will instantly be rejected from any new order checkout inputs.
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

export default Promos;
