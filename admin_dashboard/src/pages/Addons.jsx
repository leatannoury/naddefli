/**
 * NADDEFLI — Addons.jsx
 * Layer: Admin — Page
 * Purpose: Add-on services management.
 * Connects to: /api/addons/admin
 */

import React, { useState, useEffect } from 'react';
import { Box, Card, Typography, Button, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, TextField, Dialog, DialogTitle, DialogContent, DialogActions, TablePagination, Stack } from '@mui/material';
import { RefreshOutlined, Add, EditOutlined, DeleteOutlined } from '@mui/icons-material';
import { addonsAPI } from '../services/api';

const Addons = () => {
  const [addons, setAddons] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [isEdit, setIsEdit] = useState(false);
  const [selected, setSelected] = useState(null);
  const [form, setForm] = useState({ name: '', price: 0.0, is_active: true });
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  const fetch = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const res = await addonsAPI.getAll();
      if (res && res.success) setAddons(res.data || []);
    } catch (e) {
      console.error('Failed to fetch addons', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetch(); }, []);

  const openCreate = () => { setIsEdit(false); setForm({ name: '', price: 0.0, is_active: true }); setDialogOpen(true); };
  const openEdit = (a) => { setIsEdit(true); setSelected(a); setForm({ name: a.name||'', price: a.price||0.0, is_active: a.is_active }); setDialogOpen(true); };

  const save = async () => {
    try {
      if (isEdit && selected) {
        await addonsAPI.update(selected.id, form);
      } else {
        await addonsAPI.create(form);
      }
      setDialogOpen(false);
      fetch(true);
    } catch (e) { console.error('Save addon failed', e); }
  };

  const remove = async (a) => {
    if (!confirm(`Delete add-on "${a.name}"?`)) return;
    try { await addonsAPI.delete(a.id); fetch(true); } catch (e) { console.error(e); }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800 }}>Global Add-ons</Typography>
          <Typography variant="body2" sx={{ color: '#697386' }}>Manage add-ons available on the booking flow.</Typography>
        </Box>
        <Stack direction="row" spacing={1}>
          <Button startIcon={<RefreshOutlined />} onClick={() => fetch(true)}>Refresh</Button>
          <Button variant="contained" startIcon={<Add />} onClick={openCreate}>Add Add-on</Button>
        </Stack>
      </Box>

      <Card>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell>Price</TableCell>
                <TableCell>Active</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {addons.slice(page*rowsPerPage, page*rowsPerPage+rowsPerPage).map((a) => (
                <TableRow key={a.id}>
                  <TableCell>{a.name}</TableCell>
                  <TableCell>${parseFloat(a.price || 0).toFixed(2)}</TableCell>
                  <TableCell>{a.is_active ? 'Yes' : 'No'}</TableCell>
                  <TableCell align="right">
                    <Button onClick={() => openEdit(a)} startIcon={<EditOutlined />}>Edit</Button>
                    <Button onClick={() => remove(a)} startIcon={<DeleteOutlined />} color="error">Delete</Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination rowsPerPageOptions={[5,10,25]} component="div" count={addons.length} page={page} rowsPerPage={rowsPerPage} onPageChange={(e,p)=>setPage(p)} onRowsPerPageChange={(e)=>{setRowsPerPage(parseInt(e.target.value,10)); setPage(0);}} />
      </Card>

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)}>
        <DialogTitle>{isEdit ? 'Edit Add-on' : 'Create Add-on'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, width: 420 }}>
            <TextField label="Name" value={form.name} onChange={(e)=>setForm({...form, name: e.target.value})} />
            <TextField label="Price" type="number" value={form.price} onChange={(e)=>setForm({...form, price: parseFloat(e.target.value) || 0})} />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
          <Button onClick={save} variant="contained">Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Addons;
