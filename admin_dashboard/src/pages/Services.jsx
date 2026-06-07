import React, { useState, useEffect, useRef } from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Switch,
  FormControlLabel,
  InputAdornment,
  Divider,
  Stack,
  CardContent,
  CardActions,
  CardMedia,
  IconButton,
  FormControl,
  Select,
  MenuItem,
  InputLabel,
  CircularProgress,
  ToggleButtonGroup,
  ToggleButton,
} from '@mui/material';
import {
  Add,
  Search,
  RefreshOutlined,
  CleaningServicesOutlined,
  EditOutlined,
  DeleteOutlined,
  AttachMoney,
  AccessTime,
  CloudUpload,
  LinkOutlined,
} from '@mui/icons-material';
import { servicesAPI } from '../services/api';
import { resolveServiceImage } from '../utils/serviceImage';

// ─── Service image card component with error fallback ────────────────────────
const ServiceCardImage = ({ service }) => {
  const [failed, setFailed] = useState(false);
  const src = resolveServiceImage(service);

  if (!src || failed) {
    return (
      <Box
        sx={{
          height: 140,
          bgcolor: '#635bff0a',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#635bff',
        }}
      >
        <CleaningServicesOutlined sx={{ fontSize: 40 }} />
      </Box>
    );
  }

  return (
    <CardMedia
      component="img"
      height="140"
      image={src}
      alt={service.name}
      sx={{ objectFit: 'cover' }}
      onError={() => setFailed(true)}
    />
  );
};

// ─── Image preview in dialog ──────────────────────────────────────────────────
const ImagePreview = ({ src }) => {
  const [failed, setFailed] = useState(false);
  if (!src || failed) return null;
  return (
    <Box
      component="img"
      src={src}
      alt="Preview"
      onError={() => setFailed(true)}
      sx={{ width: '100%', maxHeight: 160, objectFit: 'cover', borderRadius: '8px', mt: 1 }}
    />
  );
};

const Services = () => {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Filters
  const [searchQuery, setSearchQuery] = useState('');
  const [sortField, setSortField] = useState('newest');

  // Dialog State
  const [dialogOpen, setDialogOpen] = useState(false);
  const [selectedService, setSelectedService] = useState(null);
  const [isEditMode, setIsEditMode] = useState(false);

  // Form Fields
  const [formName, setFormName] = useState('');
  const [formDescription, setFormDescription] = useState('');
  const [formBasePrice, setFormBasePrice] = useState('');
  const [formDuration, setFormDuration] = useState('');
  const [formImage, setFormImage] = useState(''); // stores the URL or filename after upload
  const [formIsActive, setFormIsActive] = useState(true);

  // Image input mode: 'url' | 'upload'
  const [imageMode, setImageMode] = useState('url');
  const [uploadingImage, setUploadingImage] = useState(false);
  const [uploadedPreviewUrl, setUploadedPreviewUrl] = useState(''); // full URL for preview after upload
  const fileInputRef = useRef(null);

  // Delete dialog
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [targetService, setTargetService] = useState(null);

  const fetchServices = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await servicesAPI.getAll();
      if (res && res.success) {
        setServices(res.data || []);
      }
    } catch (error) {
      console.error('Failed to retrieve services list:', error);
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchServices();
  }, []);

  const handleManualRefresh = () => {
    fetchServices();
  };

  // Reset form fields
  const resetForm = () => {
    setFormName('');
    setFormDescription('');
    setFormBasePrice('');
    setFormDuration('');
    setFormImage('');
    setFormIsActive(true);
    setSelectedService(null);
    setImageMode('url');
    setUploadedPreviewUrl('');
  };

  // Open Dialog for Create
  const handleOpenCreate = () => {
    resetForm();
    setIsEditMode(false);
    setDialogOpen(true);
  };

  // Open Dialog for Edit
  const handleOpenEdit = (service) => {
    setSelectedService(service);
    setFormName(service.name || '');
    setFormDescription(service.description || '');
    setFormBasePrice(service.base_price ? parseFloat(service.base_price).toString() : '');
    setFormDuration(service.duration_hours ? parseFloat(service.duration_hours).toString() : '');
    // Use image_url if available, otherwise raw image
    const existingImg = service.image_url || service.image || '';
    setFormImage(existingImg);
    setFormIsActive(service.is_active !== false);
    setIsEditMode(true);
    setImageMode('url');
    setUploadedPreviewUrl('');
    setDialogOpen(true);
  };

  // Handle file upload
  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingImage(true);
    try {
      const res = await servicesAPI.uploadImage(file);
      if (res && res.success) {
        const { filename, image_url } = res.data;
        setFormImage(filename); // store filename; backend will resolve full URL
        setUploadedPreviewUrl(image_url || '');
      } else {
        alert('Image upload failed. Please try again.');
      }
    } catch (err) {
      console.error('Image upload error:', err);
      const msg = err?.response?.data?.message || err.message;
      alert(`Image upload failed: ${msg}`);
    } finally {
      setUploadingImage(false);
      // Reset file input so same file can be re-selected
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  // Determine preview URL for the dialog
  const getDialogPreviewUrl = () => {
    if (imageMode === 'upload') return uploadedPreviewUrl;
    return formImage;
  };

  // Save Service (Create or Update)
  const handleSaveService = async () => {
    const name = (formName || '').toString().trim();
    const normalizeNumber = (v) => {
      if (v === undefined || v === null) return NaN;
      let s = String(v).trim();
      if (s === '') return NaN;
      s = s.replace(/\u066B/g, '.').replace(/,/g, '.').replace(/\u066C/g, '').replace(/\s+/g, '');
      const cleaned = s.replace(/[^0-9.\-]/g, '');
      if (cleaned === '') return NaN;
      const n = parseFloat(cleaned);
      return Number.isFinite(n) ? n : NaN;
    };

    const basePriceNum = normalizeNumber(formBasePrice);
    const durationNum = normalizeNumber(formDuration);

    if (!name || Number.isNaN(basePriceNum) || Number.isNaN(durationNum) || basePriceNum <= 0 || durationNum <= 0) {
      alert(`Please provide a valid name, base price (>0) and duration hours (>0).\nParsed values -> name: "${name}", basePrice: ${basePriceNum}, duration: ${durationNum}`);
      return;
    }

    const serviceData = {
      name,
      description: formDescription,
      base_price: basePriceNum,
      duration_hours: durationNum,
      image: formImage || null,
      is_active: formIsActive,
    };

    try {
      let res;
      if (isEditMode && selectedService) {
        res = await servicesAPI.update(selectedService.id, serviceData);
      } else {
        res = await servicesAPI.create(serviceData);
      }

      if (res && res.success) {
        fetchServices(true);
        setDialogOpen(false);
        resetForm();
      }
    } catch (err) {
      console.error('Failed to save cleaning service:', err);
      const serverMsg = err?.response?.data?.message || err?.response?.data?.error || err.message;
      alert(`Failed to save service: ${serverMsg}`);
    }
  };

  // Fast Toggle Active/Inactive switch
  const handleToggleActive = async (service) => {
    try {
      const nextActiveState = !service.is_active;
      const res = await servicesAPI.update(service.id, {
        name: service.name,
        base_price: service.base_price,
        duration_hours: service.duration_hours,
        is_active: nextActiveState,
      });
      if (res && res.success) {
        setServices((prev) => prev.map((s) => (s.id === service.id ? { ...s, is_active: nextActiveState } : s)));
      }
    } catch (err) {
      console.error('Failed to toggle active state:', err);
    }
  };

  // Delete Action triggers
  const handleStartDelete = (service) => {
    setTargetService(service);
    setDeleteOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (!targetService) return;
    try {
      const res = await servicesAPI.delete(targetService.id);
      if (res && res.success) {
        fetchServices(true);
        setDeleteOpen(false);
        setTargetService(null);
      }
    } catch (err) {
      console.error('Failed to delete service offering:', err);
    }
  };

  // Filtering Logic
  const filteredServices = services
    .filter((s) => {
      if (searchQuery.trim() !== '') {
        const query = searchQuery.toLowerCase();
        const name = s.name?.toLowerCase() || '';
        const desc = s.description?.toLowerCase() || '';
        return name.includes(query) || desc.includes(query);
      }
      return true;
    })
    .sort((a, b) => {
      if (sortField === 'name_asc') return (a.name || '').localeCompare(b.name || '');
      if (sortField === 'name_desc') return (b.name || '').localeCompare(a.name || '');
      if (sortField === 'price_asc') return (parseFloat(a.base_price) || 0) - (parseFloat(b.base_price) || 0);
      if (sortField === 'price_desc') return (parseFloat(b.base_price) || 0) - (parseFloat(a.base_price) || 0);
      if (sortField === 'duration_asc') return (parseFloat(a.duration_hours) || 0) - (parseFloat(b.duration_hours) || 0);
      if (sortField === 'duration_desc') return (parseFloat(b.duration_hours) || 0) - (parseFloat(a.duration_hours) || 0);
      return new Date(b.created_at || 0) - new Date(a.created_at || 0);
    });

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Header Row */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.04em' }}>
            Service Offerings
          </Typography>
          <Typography variant="body1" sx={{ color: '#697386', mt: 0.5 }}>
            Configure cleaning options, base rates, duration estimations, and category visibility.
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
              '&:hover': { borderColor: '#635bff', bgcolor: '#f6f9fc' },
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
              '&:hover': { bgcolor: '#0A2540' },
            }}
          >
            Add Offering
          </Button>
        </Stack>
      </Box>

      {/* Control / Search Card */}
      <Card sx={{ borderRadius: '12px', border: '1px solid #e6ebf1', boxShadow: 'none', p: 3 }}>
        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems="center">
          <TextField
            placeholder="Search service names or descriptions..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            size="small"
            sx={{
              minWidth: { xs: '100%', sm: 380 },
              '& .MuiOutlinedInput-root': {
                borderRadius: '8px',
                bgcolor: '#f6f9fc',
                '& fieldset': { borderColor: '#e6ebf1' },
                '&:hover fieldset': { borderColor: '#cbd5e1' },
                '&.Mui-focused fieldset': { borderColor: '#635bff' },
              },
            }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search sx={{ color: '#a3b1c2' }} />
                </InputAdornment>
              ),
            }}
          />
          <FormControl size="small" sx={{ minWidth: 180 }}>
            <InputLabel id="sort-services-label">Sort by</InputLabel>
            <Select
              labelId="sort-services-label"
              value={sortField}
              label="Sort by"
              onChange={(e) => setSortField(e.target.value)}
              sx={{ bgcolor: '#fff', borderRadius: '8px' }}
            >
              <MenuItem value="newest">Newest first</MenuItem>
              <MenuItem value="name_asc">Name A → Z</MenuItem>
              <MenuItem value="name_desc">Name Z → A</MenuItem>
              <MenuItem value="price_asc">Price low → high</MenuItem>
              <MenuItem value="price_desc">Price high → low</MenuItem>
              <MenuItem value="duration_asc">Duration short → long</MenuItem>
              <MenuItem value="duration_desc">Duration long → short</MenuItem>
            </Select>
          </FormControl>
        </Stack>
      </Card>

      {/* Services Grid */}
      <Grid container spacing={3}>
        {loading && filteredServices.length === 0 ? (
          <Grid item xs={12}>
            <Box sx={{ py: 8, textAlign: 'center', color: '#697386' }}>Retrieving platform catalog...</Box>
          </Grid>
        ) : filteredServices.length === 0 ? (
          <Grid item xs={12}>
            <Box sx={{ py: 8, textAlign: 'center', color: '#697386' }}>
              No cleaning services cataloged. Add a new service offering above.
            </Box>
          </Grid>
        ) : (
          filteredServices.map((service) => (
            <Grid item xs={12} sm={6} md={4} key={service.id}>
              <Card
                sx={{
                  height: '100%',
                  borderRadius: '12px',
                  border: '1px solid #e6ebf1',
                  boxShadow: 'none',
                  display: 'flex',
                  flexDirection: 'column',
                  position: 'relative',
                  opacity: service.is_active ? 1 : 0.75,
                  transition: 'all 0.25s ease',
                  '&:hover': { borderColor: '#cbd5e1', boxShadow: '0 4px 12px rgba(0,0,0,0.015)' },
                }}
              >
                <ServiceCardImage service={service} />

                <CardContent sx={{ flexGrow: 1, p: 2.5 }}>
                  <Typography variant="h6" sx={{ fontWeight: 700, color: '#0A2540', letterSpacing: '-0.02em', mb: 1 }}>
                    {service.name}
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{
                      color: '#697386',
                      mb: 3.5,
                      height: 40,
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      display: '-webkit-box',
                      WebkitLineClamp: 2,
                      WebkitBoxOrient: 'vertical',
                    }}
                  >
                    {service.description || 'No service summary provided.'}
                  </Typography>

                  <Divider />

                  <Stack direction="row" spacing={3} sx={{ mt: 2.5 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <AttachMoney sx={{ color: '#00d4b6', fontSize: 20 }} />
                      <Box>
                        <Typography variant="caption" sx={{ color: '#697386', display: 'block', fontWeight: 500 }}>
                          BASE PRICE
                        </Typography>
                        <Typography variant="body2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                          ${parseFloat(service.base_price).toFixed(2)}
                        </Typography>
                      </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <AccessTime sx={{ color: '#635bff', fontSize: 20 }} />
                      <Box>
                        <Typography variant="caption" sx={{ color: '#697386', display: 'block', fontWeight: 500 }}>
                          EST. TIME
                        </Typography>
                        <Typography variant="body2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                          {parseFloat(service.duration_hours)} hours
                        </Typography>
                      </Box>
                    </Box>
                  </Stack>
                </CardContent>

                <CardActions sx={{ px: 2.5, pb: 2.5, pt: 0, justifyContent: 'space-between', alignItems: 'center' }}>
                  <FormControlLabel
                    control={
                      <Switch
                        size="small"
                        checked={service.is_active !== false}
                        onChange={() => handleToggleActive(service)}
                        sx={{
                          '& .MuiSwitch-switchBase.Mui-checked': { color: '#635bff' },
                          '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { bgcolor: '#635bff' },
                        }}
                      />
                    }
                    label="Active"
                    componentsProps={{ typography: { fontSize: '0.85rem', fontWeight: 600, color: '#697386' } }}
                  />

                  <Stack direction="row" spacing={0.5}>
                    <IconButton
                      size="small"
                      onClick={() => handleOpenEdit(service)}
                      sx={{ color: '#0A2540', '&:hover': { bgcolor: '#f6f9fc' } }}
                    >
                      <EditOutlined fontSize="small" />
                    </IconButton>
                    <IconButton
                      size="small"
                      onClick={() => handleStartDelete(service)}
                      sx={{ color: '#ff5f5f', '&:hover': { bgcolor: 'rgba(255, 95, 95, 0.05)' } }}
                    >
                      <DeleteOutlined fontSize="small" />
                    </IconButton>
                  </Stack>
                </CardActions>
              </Card>
            </Grid>
          ))
        )}
      </Grid>

      {/* CRUD dialog */}
      <Dialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        fullWidth
        maxWidth="sm"
        PaperProps={{ sx: { borderRadius: '16px', p: 1 } }}
      >
        <DialogTitle sx={{ fontWeight: 800, color: '#0A2540', pb: 1 }}>
          {isEditMode ? 'Modify Cleaning Service' : 'Add New Service Offering'}
        </DialogTitle>
        <DialogContent sx={{ py: 2 }}>
          <Stack spacing={2.5} sx={{ mt: 1 }}>
            <TextField
              label="Service Name"
              fullWidth
              value={formName}
              onChange={(e) => setFormName(e.target.value)}
              placeholder="e.g. Standard Kitchen Deep Cleaning"
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
            />

            <TextField
              label="Description"
              fullWidth
              multiline
              rows={3}
              value={formDescription}
              onChange={(e) => setFormDescription(e.target.value)}
              placeholder="Detail the parameters of this cleaning task (what's included, conditions, etc.)..."
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
            />

            <Grid container spacing={2.5}>
              <Grid item xs={6}>
                <TextField
                  label="Base Price"
                  fullWidth
                  type="number"
                  value={formBasePrice}
                  onChange={(e) => setFormBasePrice(e.target.value)}
                  placeholder="29.99"
                  InputProps={{ startAdornment: <InputAdornment position="start">$</InputAdornment> }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  label="Estimated Hours"
                  fullWidth
                  type="number"
                  value={formDuration}
                  onChange={(e) => setFormDuration(e.target.value)}
                  placeholder="2.5"
                  InputProps={{ endAdornment: <InputAdornment position="end">hrs</InputAdornment> }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
                />
              </Grid>
            </Grid>

            {/* Image Section */}
            <Box sx={{ p: 2, borderRadius: '12px', border: '1px solid #e6ebf1', bgcolor: '#f6f9fc' }}>
              <Typography variant="subtitle1" sx={{ fontWeight: 700, color: '#0A2540', mb: 1.5 }}>
                Service Banner Image
              </Typography>

              <ToggleButtonGroup
                value={imageMode}
                exclusive
                onChange={(_, val) => {
                  if (val) {
                    setImageMode(val);
                    setFormImage('');
                    setUploadedPreviewUrl('');
                  }
                }}
                size="small"
                sx={{ mb: 2 }}
              >
                <ToggleButton value="url" sx={{ textTransform: 'none', px: 2 }}>
                  <LinkOutlined sx={{ mr: 0.5, fontSize: 18 }} /> URL
                </ToggleButton>
                <ToggleButton value="upload" sx={{ textTransform: 'none', px: 2 }}>
                  <CloudUpload sx={{ mr: 0.5, fontSize: 18 }} /> Upload File
                </ToggleButton>
              </ToggleButtonGroup>

              {imageMode === 'url' ? (
                <TextField
                  label="Image URL"
                  fullWidth
                  value={formImage}
                  onChange={(e) => setFormImage(e.target.value)}
                  placeholder="https://example.com/image.jpg"
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: '8px' } }}
                />
              ) : (
                <Box>
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    style={{ display: 'none' }}
                    onChange={handleFileChange}
                  />
                  <Button
                    variant="outlined"
                    startIcon={uploadingImage ? <CircularProgress size={16} /> : <CloudUpload />}
                    onClick={() => fileInputRef.current?.click()}
                    disabled={uploadingImage}
                    fullWidth
                    sx={{
                      textTransform: 'none',
                      borderRadius: '8px',
                      borderColor: '#635bff',
                      color: '#635bff',
                      py: 1.5,
                      '&:hover': { borderColor: '#0A2540', color: '#0A2540' },
                    }}
                  >
                    {uploadingImage ? 'Uploading...' : formImage ? 'Replace Image' : 'Choose Image File'}
                  </Button>
                  {formImage && !uploadingImage && (
                    <Typography variant="caption" sx={{ color: '#697386', mt: 0.5, display: 'block' }}>
                      ✓ Image uploaded successfully
                    </Typography>
                  )}
                </Box>
              )}

              {/* Image preview */}
              <ImagePreview src={getDialogPreviewUrl()} />
            </Box>

            <FormControlLabel
              control={
                <Switch
                  checked={formIsActive}
                  onChange={(e) => setFormIsActive(e.target.checked)}
                  sx={{
                    '& .MuiSwitch-switchBase.Mui-checked': { color: '#635bff' },
                    '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { bgcolor: '#635bff' },
                  }}
                />
              }
              label="Make active immediately"
              componentsProps={{ typography: { fontWeight: 600, color: '#424e5e' } }}
            />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ p: 2.5, gap: 1.5 }}>
          <Button
            onClick={() => setDialogOpen(false)}
            variant="outlined"
            sx={{ textTransform: 'none', borderColor: '#e6ebf1', color: '#0A2540' }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleSaveService}
            variant="contained"
            sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none', '&:hover': { bgcolor: '#0A2540' } }}
          >
            {isEditMode ? 'Update Service' : 'Publish Service'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete confirmation dialog */}
      <Dialog
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        fullWidth
        maxWidth="xs"
        PaperProps={{ sx: { borderRadius: '12px' } }}
      >
        <DialogTitle sx={{ fontWeight: 700, color: '#0A2540', pb: 1 }}>Delete Service?</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ color: '#697386' }}>
            Are you sure you want to permanently delete <strong>{targetService?.name}</strong> from the cleaning
            catalog?
            <br />
            <br />
            Historical appointments linking to this service will remain unchanged, but customers won't be able to
            book it again.
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

export default Services;
