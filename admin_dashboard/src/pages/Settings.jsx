import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Button,
  TextField,
  Switch,
  FormControlLabel,
  Divider,
  Stack,
  InputAdornment,
  Alert,
  CircularProgress
} from '@mui/material';
import {
  SaveOutlined,
  RefreshOutlined,
  BusinessOutlined,
  ContactSupportOutlined,
  EngineeringOutlined,
  SettingsSuggestOutlined
} from '@mui/icons-material';
import { settingsAPI } from '../services/api';

const Settings = () => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  // Form Fields
  const [businessName, setBusinessName] = useState('');
  const [supportPhone, setSupportPhone] = useState('');
  const [supportEmail, setSupportEmail] = useState('');
  const [bookingLimit, setBookingLimit] = useState(20);
  const [defaultPricing, setDefaultPricing] = useState(15.0);
  const [allowSameDay, setAllowSameDay] = useState(true);

  const fetchSettings = async () => {
    setLoading(true);
    setSuccessMsg('');
    setErrorMsg('');

    try {
      const res = await settingsAPI.get();
      if (res && res.success) {
        const data = res.data || {};
        setBusinessName(data.businessName || 'Naddefli Cleaning Services');
        setSupportPhone(data.supportPhone || '+1 (555) 019-2834');
        setSupportEmail(data.supportEmail || 'support@naddefli.com');
        setBookingLimit(parseInt(data.bookingLimitPerDay) || 20);
        setDefaultPricing(parseFloat(data.defaultPricingPerHour) || 15.0);
        setAllowSameDay(data.allowSameDayBookings !== false);
      }
    } catch (err) {
      console.error('Failed to retrieve system settings:', err);
      setErrorMsg('Could not fetch settings from Node.js server. Using local defaults.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleSaveSettings = async () => {
    setSaving(true);
    setSuccessMsg('');
    setErrorMsg('');

    const payload = {
      businessName,
      supportPhone,
      supportEmail,
      bookingLimitPerDay: parseInt(bookingLimit),
      defaultPricingPerHour: parseFloat(defaultPricing),
      allowSameDayBookings: allowSameDay
    };

    try {
      const res = await settingsAPI.update(payload);
      if (res && res.success) {
        setSuccessMsg('System configuration settings saved successfully!');
      } else {
        setErrorMsg('Failed to persist settings details.');
      }
    } catch (err) {
      console.error('Failed to update platform settings:', err);
      setErrorMsg('Error sending update request to Node.js backend.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: 400, gap: 2 }}>
        <CircularProgress sx={{ color: '#635bff' }} />
        <Typography variant="body2" sx={{ color: '#697386' }}>Loading system configurations...</Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            System Settings
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Configure business information, support contact details, and operational limits.
          </Typography>
        </Box>
        <Button
          variant="outlined"
          startIcon={<RefreshOutlined />}
          onClick={fetchSettings}
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
          Refresh Settings
        </Button>
      </Box>

      {/* Notifications feed */}
      {successMsg && <Alert severity="success" sx={{ borderRadius: '8px' }}>{successMsg}</Alert>}
      {errorMsg && <Alert severity="error" sx={{ borderRadius: '8px' }}>{errorMsg}</Alert>}

      <Grid container spacing={4}>
        {/* Profile and Contacts Section */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 4, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 1, letterSpacing: '-0.02em', display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <BusinessOutlined sx={{ color: '#635bff' }} /> Business Unit Profile
            </Typography>
            <Typography variant="caption" sx={{ color: '#697386', display: 'block', mb: 3 }}>
              Enter information relating to this branch or business unit displayed on receipts and applications.
            </Typography>
            
            <Stack spacing={3}>
              <TextField
                label="Registered Business Name"
                fullWidth
                value={businessName}
                onChange={(e) => setBusinessName(e.target.value)}
                sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
              />

              <Divider />

              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: '#0A2540', mb: -1, display: 'flex', alignItems: 'center', gap: 1 }}>
                <ContactSupportOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} /> Customer Support Coordinates
              </Typography>

              <TextField
                label="Support Phone Number"
                fullWidth
                value={supportPhone}
                onChange={(e) => setSupportPhone(e.target.value)}
                sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
              />

              <TextField
                label="Support Email Address"
                fullWidth
                value={supportEmail}
                onChange={(e) => setSupportEmail(e.target.value)}
                sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
              />
            </Stack>
          </Card>
        </Grid>

        {/* Operating Limits and Rates Section */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 4, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none' }}>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 1, letterSpacing: '-0.02em', display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <EngineeringOutlined sx={{ color: '#00d4b6' }} /> Operational Limits & Rates
            </Typography>
            <Typography variant="caption" sx={{ color: '#697386', display: 'block', mb: 3 }}>
              Calibrate business boundaries, booking thresholds, and base parameters.
            </Typography>

            <Stack spacing={3}>
              <TextField
                label="Maximum Appointments / Day"
                fullWidth
                type="number"
                value={bookingLimit}
                onChange={(e) => setBookingLimit(e.target.value)}
                helperText="Auto-rejects bookings when this threshold is met in a given region."
                sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
              />

              <TextField
                label="Hourly Invoice Rate for Custom Cleanings"
                fullWidth
                type="number"
                value={defaultPricing}
                onChange={(e) => setDefaultPricing(e.target.value)}
                InputProps={{
                  startAdornment: <InputAdornment position="start">$</InputAdornment>,
                  endAdornment: <InputAdornment position="end">/ hr</InputAdornment>
                }}
                helperText="Applied automatically in custom cleaning estimations."
                sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
              />

              <Divider />

              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: '#0A2540', mb: -1, display: 'flex', alignItems: 'center', gap: 1 }}>
                <SettingsSuggestOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} /> Scheduling Preferences
              </Typography>

              <FormControlLabel
                control={
                  <Switch
                    checked={allowSameDay}
                    onChange={(e) => setAllowSameDay(e.target.checked)}
                    sx={{
                      '& .MuiSwitch-switchBase.Mui-checked': { color: '#635bff' },
                      '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { bgcolor: '#635bff' }
                    }}
                  />
                }
                label="Allow same-day urgency checkouts"
                componentsProps={{ typography: { fontWeight: 600, color: '#424e5e', fontSize: '0.92rem' } }}
              />
            </Stack>
          </Card>
        </Grid>
      </Grid>

      {/* Form Submission Actions */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mt: 2 }}>
        <Button
          variant="outlined"
          onClick={fetchSettings}
          sx={{
            borderColor: '#e6ebf1',
            color: '#0A2540',
            textTransform: 'none',
            px: 4,
            py: 1.5,
            borderRadius: '8px',
            fontWeight: 600,
            '&:hover': { borderColor: '#635bff', bgcolor: '#f6f9fc' }
          }}
        >
          Discard Changes
        </Button>
        <Button
          variant="contained"
          startIcon={<SaveOutlined />}
          onClick={handleSaveSettings}
          disabled={saving}
          sx={{
            bgcolor: '#635bff',
            textTransform: 'none',
            boxShadow: 'none',
            px: 4,
            py: 1.5,
            borderRadius: '8px',
            fontWeight: 600,
            '&:hover': { bgcolor: '#0A2540' }
          }}
        >
          {saving ? 'Saving...' : 'Apply Configurations'}
        </Button>
      </Box>
    </Box>
  );
};

export default Settings;
