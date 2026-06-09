/**
 * NADDEFLI — Settings.jsx
 * Layer: Admin — Page
 * Purpose: Edit business settings: hourly rates, support contact.
 * Connects to: GET/PUT /api/admin/settings
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Card,
  Typography,
  Button,
  TextField,
  Stack,
  Alert,
  CircularProgress,
  Divider,
  InputAdornment,
} from '@mui/material';
import { SaveOutlined, RefreshOutlined, ContactSupportOutlined, AttachMoneyOutlined } from '@mui/icons-material';
import { settingsAPI } from '../services/api';

const Settings = () => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  const [supportPhone, setSupportPhone] = useState('');
  const [supportEmail, setSupportEmail] = useState('');
  const [normalHourlyRate, setNormalHourlyRate] = useState(4.0);
  const [deepHourlyRate, setDeepHourlyRate] = useState(6.0);

  const fetchSettings = async () => {
    setLoading(true);
    setSuccessMsg('');
    setErrorMsg('');
    try {
      const res = await settingsAPI.get();
      if (res && res.success) {
        const data = res.data || {};
        setSupportPhone(data.supportPhone || '');
        setSupportEmail(data.supportEmail || '');
        setNormalHourlyRate(parseFloat(data.normalHourlyRate) || 4.0);
        setDeepHourlyRate(parseFloat(data.deepHourlyRate) || 6.0);
      }
    } catch (err) {
      setErrorMsg('Could not load settings.');
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
    try {
      const res = await settingsAPI.update({
        supportPhone,
        supportEmail,
        normalHourlyRate,
        deepHourlyRate,
      });
      if (res && res.success) {
        setSuccessMsg('Settings saved. Contact info and rates sync to the mobile app.');
      } else {
        setErrorMsg('Failed to save settings.');
      }
    } catch (err) {
      setErrorMsg('Error saving settings.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: 400, gap: 2 }}>
        <CircularProgress sx={{ color: '#635bff' }} />
        <Typography variant="body2" sx={{ color: '#697386' }}>Loading settings…</Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, maxWidth: 720 }}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
          Settings
        </Typography>
        <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
          Customer support contact and hourly rates shown in the mobile app.
        </Typography>
      </Box>

      {successMsg && <Alert severity="success">{successMsg}</Alert>}
      {errorMsg && <Alert severity="error">{errorMsg}</Alert>}

      <Card sx={{ p: 4, borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none' }}>
        <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
          <ContactSupportOutlined sx={{ color: '#635bff' }} /> Customer Support
        </Typography>
        <Typography variant="body2" sx={{ color: '#697386', mb: 3 }}>
          These details appear in the app under Help & Support.
        </Typography>
        <Stack spacing={2.5}>
          <TextField label="Support phone" fullWidth value={supportPhone} onChange={(e) => setSupportPhone(e.target.value)} />
          <TextField label="Support email" fullWidth value={supportEmail} onChange={(e) => setSupportEmail(e.target.value)} />
        </Stack>

        <Divider sx={{ my: 4 }} />

        <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
          <AttachMoneyOutlined sx={{ color: '#00d4b6' }} /> Hourly Rates
        </Typography>
        <Typography variant="body2" sx={{ color: '#697386', mb: 3 }}>
          Used for price calculation in the app when customers book cleanings.
        </Typography>
        <Stack spacing={2.5}>
          <TextField
            label="Standard cleaning rate"
            type="number"
            fullWidth
            value={normalHourlyRate}
            onChange={(e) => setNormalHourlyRate(e.target.value)}
            InputProps={{ startAdornment: <InputAdornment position="start">$</InputAdornment>, endAdornment: <InputAdornment position="end">/hr</InputAdornment> }}
          />
          <TextField
            label="Deep cleaning rate"
            type="number"
            fullWidth
            value={deepHourlyRate}
            onChange={(e) => setDeepHourlyRate(e.target.value)}
            InputProps={{ startAdornment: <InputAdornment position="start">$</InputAdornment>, endAdornment: <InputAdornment position="end">/hr</InputAdornment> }}
          />
        </Stack>
      </Card>

      <Stack direction="row" spacing={2} justifyContent="flex-end">
        <Button variant="outlined" startIcon={<RefreshOutlined />} onClick={fetchSettings} sx={{ textTransform: 'none' }}>
          Reset
        </Button>
        <Button variant="contained" startIcon={<SaveOutlined />} onClick={handleSaveSettings} disabled={saving} sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none' }}>
          {saving ? 'Saving…' : 'Save settings'}
        </Button>
      </Stack>
    </Box>
  );
};

export default Settings;
