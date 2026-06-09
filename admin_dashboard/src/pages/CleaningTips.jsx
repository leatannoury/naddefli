/**
 * NADDEFLI — CleaningTips.jsx
 * Layer: Admin — Page
 * Purpose: Manage cleaning tips shown in mobile app.
 * Connects to: /api/cleaning-tips/admin
 */

import React, { useState, useEffect } from 'react';
import {
  Box, Card, Typography, Button, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TextField, Dialog, DialogTitle, DialogContent, DialogActions,
  TablePagination, Stack, Switch, FormControlLabel, MenuItem, Select, FormControl,
  InputLabel, Chip,
} from '@mui/material';
import { RefreshOutlined, Add, EditOutlined, DeleteOutlined, LightbulbOutlined } from '@mui/icons-material';
import { cleaningTipsAPI } from '../services/api';

const GRADIENT_PRESETS = [
  { label: 'Ocean Blue', start: '#0058BC', end: '#0070EB' },
  { label: 'Indigo', start: '#312E81', end: '#6366F1' },
  { label: 'Teal Fresh', start: '#0F766E', end: '#14B8A6' },
  { label: 'Sunset', start: '#9A3412', end: '#F97316' },
  { label: 'Purple', start: '#4C4ACA', end: '#6664E4' },
];

const emptyForm = () => ({
  title: '',
  content: '',
  image_url: '',
  gradient_start: '#0F766E',
  gradient_end: '#14B8A6',
  is_active: true,
});

const CleaningTips = () => {
  const [tips, setTips] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [isEdit, setIsEdit] = useState(false);
  const [selected, setSelected] = useState(null);
  const [form, setForm] = useState(emptyForm());
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [preset, setPreset] = useState('Teal Fresh');

  const fetch = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const res = await cleaningTipsAPI.getAll();
      if (res && res.success) setTips(res.data || []);
    } catch (e) {
      console.error('Failed to fetch cleaning tips', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetch(); }, []);

  const applyPreset = (label) => {
    const p = GRADIENT_PRESETS.find((g) => g.label === label);
    if (p) {
      setPreset(label);
      setForm((f) => ({ ...f, gradient_start: p.start, gradient_end: p.end }));
    }
  };

  const openCreate = () => {
    setIsEdit(false);
    setForm(emptyForm());
    setPreset('Teal Fresh');
    setDialogOpen(true);
  };

  const openEdit = (tip) => {
    setIsEdit(true);
    setSelected(tip);
    const match = GRADIENT_PRESETS.find(
      (g) => g.start === tip.gradient_start && g.end === tip.gradient_end
    );
    setPreset(match?.label || 'Custom');
    setForm({
      title: tip.title || '',
      content: tip.content || '',
      image_url: tip.image_url || '',
      gradient_start: tip.gradient_start || '#0F766E',
      gradient_end: tip.gradient_end || '#14B8A6',
      is_active: tip.is_active !== false,
    });
    setDialogOpen(true);
  };

  const save = async () => {
    if (!form.title.trim() || !form.content.trim()) return;
    try {
      if (isEdit && selected) {
        await cleaningTipsAPI.update(selected.id, form);
      } else {
        await cleaningTipsAPI.create(form);
      }
      setDialogOpen(false);
      fetch(true);
    } catch (e) {
      console.error('Save tip failed', e);
    }
  };

  const remove = async (tip) => {
    if (!confirm(`Delete tip "${tip.title}"?`)) return;
    try {
      await cleaningTipsAPI.delete(tip.id);
      fetch(true);
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540' }}>Cleaning Tips</Typography>
          <Typography variant="body2" sx={{ color: '#697386', mt: 0.5 }}>
            Manage tips shown as &quot;Tip of the Day&quot; in the mobile app. One random tip is picked each day.
          </Typography>
        </Box>
        <Stack direction="row" spacing={1}>
          <Button startIcon={<RefreshOutlined />} onClick={() => fetch(true)} sx={{ textTransform: 'none' }}>Refresh</Button>
          <Button variant="contained" startIcon={<Add />} onClick={openCreate} sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none' }}>
            Add Tip
          </Button>
        </Stack>
      </Box>

      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none' }}>
        <TableContainer>
          <Table>
            <TableHead sx={{ bgcolor: '#f6f9fc' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 700 }}>Title</TableCell>
                <TableCell sx={{ fontWeight: 700 }}>Content</TableCell>
                <TableCell sx={{ fontWeight: 700 }}>Style</TableCell>
                <TableCell sx={{ fontWeight: 700 }}>Active</TableCell>
                <TableCell align="right" sx={{ fontWeight: 700 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={5}>Loading...</TableCell></TableRow>
              ) : tips.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((tip) => (
                <TableRow key={tip.id} hover>
                  <TableCell sx={{ fontWeight: 600, maxWidth: 180 }}>{tip.title}</TableCell>
                  <TableCell sx={{ color: '#697386', maxWidth: 320 }}>
                    <Typography variant="body2" noWrap>{tip.content}</Typography>
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Box sx={{ width: 28, height: 28, borderRadius: '6px', background: `linear-gradient(135deg, ${tip.gradient_start}, ${tip.gradient_end})` }} />
                      {tip.image_url ? <Chip size="small" label="Image" /> : null}
                    </Box>
                  </TableCell>
                  <TableCell>{tip.is_active ? 'Yes' : 'No'}</TableCell>
                  <TableCell align="right">
                    <Button size="small" onClick={() => openEdit(tip)} startIcon={<EditOutlined />} sx={{ textTransform: 'none' }}>Edit</Button>
                    <Button size="small" onClick={() => remove(tip)} startIcon={<DeleteOutlined />} color="error" sx={{ textTransform: 'none' }}>Delete</Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={tips.length}
          page={page}
          rowsPerPage={rowsPerPage}
          onPageChange={(_, p) => setPage(p)}
          onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
        />
      </Card>

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth PaperProps={{ sx: { borderRadius: '16px' } }}>
        <DialogTitle sx={{ fontWeight: 700 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <LightbulbOutlined sx={{ color: '#635bff' }} />
            {isEdit ? 'Edit Cleaning Tip' : 'Create Cleaning Tip'}
          </Box>
        </DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5, pt: 1 }}>
            <TextField label="Title" fullWidth value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. Vacuum Before Mopping" />
            <TextField label="Tip content" fullWidth multiline rows={3} value={form.content} onChange={(e) => setForm({ ...form, content: e.target.value })} placeholder="The helpful cleaning advice..." />
            <TextField label="Background image URL (optional)" fullWidth value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })} placeholder="https://..." />
            <FormControl fullWidth>
              <InputLabel>Gradient preset</InputLabel>
              <Select label="Gradient preset" value={preset} onChange={(e) => applyPreset(e.target.value)}>
                {GRADIENT_PRESETS.map((g) => (
                  <MenuItem key={g.label} value={g.label}>{g.label}</MenuItem>
                ))}
                <MenuItem value="Custom">Custom</MenuItem>
              </Select>
            </FormControl>
            <Stack direction="row" spacing={2}>
              <TextField label="Gradient start" fullWidth value={form.gradient_start} onChange={(e) => { setPreset('Custom'); setForm({ ...form, gradient_start: e.target.value }); }} />
              <TextField label="Gradient end" fullWidth value={form.gradient_end} onChange={(e) => { setPreset('Custom'); setForm({ ...form, gradient_end: e.target.value }); }} />
            </Stack>
            <Box sx={{ height: 72, borderRadius: '12px', background: `linear-gradient(135deg, ${form.gradient_start}, ${form.gradient_end})`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, px: 2, textAlign: 'center' }}>
              Preview: {form.title || 'Tip title'}
            </Box>
            <FormControlLabel control={<Switch checked={form.is_active} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />} label="Active" />
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setDialogOpen(false)} sx={{ textTransform: 'none' }}>Cancel</Button>
          <Button onClick={save} variant="contained" sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none' }}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default CleaningTips;
