import React from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, Grid, Box, Typography, Divider, Chip, List, ListItem, ListItemText, Stack } from '@mui/material';
import { getBookingServiceLabel } from '../utils/bookingDisplay';
import {
  CalendarMonth,
  AccessTime,
  PlaceOutlined,
  NotesOutlined,
  PersonOutlined,
  PhoneOutlined,
  ReceiptOutlined,
  CheckCircleOutlined,
  CleaningServicesOutlined,
  HomeOutlined
} from '@mui/icons-material';

const BookingDetails = ({ open, booking, onClose, onAccept, onCancel, onComplete }) => {
  if (!booking) return null;

  // Formatting helper
  const formatDate = (d) => {
    return new Date(d).toLocaleDateString(undefined, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  // Parse extras from booking JSON or CSV
  let extrasList = [];
  try {
    if (booking.extras) {
      if (booking.extras.startsWith('[') || booking.extras.startsWith('{')) {
        extrasList = JSON.parse(booking.extras);
        if (!Array.isArray(extrasList)) {
          extrasList = Object.keys(extrasList).filter(k => extrasList[k]);
        }
      } else {
        extrasList = booking.extras.split(',').map(e => e.trim()).filter(Boolean);
      }
    }
  } catch (err) {
    extrasList = booking.extras.split(',').map(e => e.trim()).filter(Boolean);
  }

  // Calculate invoice elements manually for high fidelity breakdown
  const duration = parseFloat(booking.duration_hours) || 1.0;
  const isDeep = booking.cleaning_type === 'deep';
  const rate = isDeep ? 6.0 : 4.0;
  const rawBase = rate * duration;
  
  let addOnsCost = 0.0;
  const ADDON_PRICES = {
    'windows cleaning': 10.0,
    'oven cleaning': 8.0,
    'fridge cleaning': 8.0,
    'balcony cleaning': 6.0,
    'inside cabinets': 5.0,
    'laundry folding': 7.0,
    'ironing': 7.0,
  };

  extrasList.forEach(extra => {
    let matched = false;
    for (const [key, p] of Object.entries(ADDON_PRICES)) {
      if (extra.toLowerCase().includes(key) || key.includes(extra.toLowerCase())) {
        addOnsCost += p;
        matched = true;
        break;
      }
    }
    if (!matched) addOnsCost += 15.0; // fallback default price
  });

  let customRoomsPrice = 0.0;
  if (booking.is_custom) {
    customRoomsPrice += (parseInt(booking.room_count) || 0) * 20.0;
    customRoomsPrice += (parseInt(booking.bathrooms_count) || 0) * 30.0;
    customRoomsPrice += (parseInt(booking.kitchens_count) || 0) * 40.0;
  }

  const subtotal = rawBase + addOnsCost + customRoomsPrice;
  const finalPrice = parseFloat(booking.total_price) || 0.0;
  const discount = subtotal - finalPrice; // Difference is the discount

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth PaperProps={{ sx: { borderRadius: '16px', p: 1 } }}>
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', pb: 1 }}>
        <Box>
          <Typography variant="h6" sx={{ fontWeight: 800, color: '#0A2540', letterSpacing: '-0.02em' }}>
              Booking Invoice #{String(booking.id || '').slice(0, 8)}
          </Typography>
          <Typography variant="caption" sx={{ color: '#697386' }}>
            Placed on {new Date(booking.created_at || new Date()).toLocaleString()}
          </Typography>
        </Box>
        <span className={`status-badge ${booking.status}`} style={{ fontSize: '0.82rem', padding: '6px 14px' }}>
          {booking.status}
        </span>
      </DialogTitle>
      <Divider />

      <DialogContent sx={{ py: 3 }}>
        <Grid container spacing={4}>
          {/* Customer & Address Details */}
          <Grid item xs={12} md={6}>
            <Stack spacing={3}>
              {/* Customer Box */}
              <Box>
                <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1.5, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                  CUSTOMER INFORMATION
                </Typography>
                <Stack spacing={1}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <PersonOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} />
                    <Typography variant="body1" sx={{ fontWeight: 600, color: '#0A2540' }}>
                      {booking.customer?.full_name || 'Anonymous User'}
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <PhoneOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', fontWeight: 500 }}>
                      {booking.customer?.phone || 'No phone recorded'}
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <PlaceOutlined sx={{ color: '#a3b1c2', fontSize: 20 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', fontWeight: 500 }}>
                      {booking.address}, {booking.city}
                    </Typography>
                  </Box>
                </Stack>
              </Box>

              {/* Booking Specifications */}
              <Box>
                <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1.5, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                  CLEANING SPECIFICATIONS
                </Typography>
                <Grid container spacing={2}>
                  <Grid item xs={12}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <CleaningServicesOutlined sx={{ color: '#635bff', fontSize: 18 }} />
                      <Typography variant="body2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                        {getBookingServiceLabel(booking)}
                      </Typography>
                    </Box>
                  </Grid>
                  <Grid item xs={6}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <CleaningServicesOutlined sx={{ color: '#635bff', fontSize: 18 }} />
                      <Typography variant="body2" sx={{ fontWeight: 600 }}>
                        {booking.cleaning_type === 'deep' ? 'Deep Cleaning' : 'Normal Cleaning'}
                      </Typography>
                    </Box>
                  </Grid>
                  <Grid item xs={6}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <HomeOutlined sx={{ color: '#635bff', fontSize: 18 }} />
                      <Typography variant="body2" sx={{ fontWeight: 600 }}>
                        {booking.property_type || 'House/Apartment'}
                      </Typography>
                    </Box>
                  </Grid>
                </Grid>

                {/* Rooms details if custom */}
                {booking.is_custom && (
                  <Box sx={{ bgcolor: '#f6f9fc', p: 1.5, borderRadius: '8px', mt: 2 }}>
                    <Typography variant="caption" sx={{ color: '#697386', fontWeight: 600, display: 'block', mb: 0.5 }}>ROOM COUNTS</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 700, color: '#0A2540' }}>
                      {booking.room_count} Bedrooms | {booking.bathrooms_count} Bathrooms | {booking.kitchens_count} Kitchens
                    </Typography>
                  </Box>
                )}
              </Box>

              {/* Time & Duration */}
              <Box>
                <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1.5, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                  SCHEDULE & TIME
                </Typography>
                <Stack spacing={1}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <CalendarMonth sx={{ color: '#a3b1c2', fontSize: 20 }} />
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#0A2540' }}>
                      {formatDate(booking.booking_date)}
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <AccessTime sx={{ color: '#a3b1c2', fontSize: 20 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', fontWeight: 500 }}>
                      {booking.start_time || booking.booking_time} to {booking.end_time || 'flexible'} ({booking.duration_hours} hours)
                    </Typography>
                  </Box>
                </Stack>
              </Box>
            </Stack>
          </Grid>

          {/* Invoice & Actions Column */}
          <Grid item xs={12} md={6}>
            <Stack spacing={3}>
              {/* Extras list if any */}
              {extrasList.length > 0 && (
                <Box>
                  <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                    ADD-ONS (EXTRAS)
                  </Typography>
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                    {extrasList.map((extra) => (
                      <Chip key={extra} label={extra} size="small" sx={{ bgcolor: '#635bff12', color: '#635bff', fontWeight: 600 }} />
                    ))}
                  </Box>
                </Box>
              )}

              {/* Invoice breakdown */}
              <Box sx={{ p: 2.5, borderRadius: '12px', bgcolor: '#f6f9fc', border: '1px solid #e6ebf1' }}>
                <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 2, letterSpacing: '0.05em', textTransform: 'uppercase', display: 'flex', alignItems: 'center', gap: 1, fontSize: '0.72rem' }}>
                  <ReceiptOutlined sx={{ fontSize: 18 }} /> INVOICE BREAKDOWN
                </Typography>
                
                <Stack spacing={1.2}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" sx={{ color: '#697386' }}>Base Rate ({duration}h x ${rate}/h)</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>${rawBase.toFixed(2)}</Typography>
                  </Box>

                  {addOnsCost > 0 && (
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2" sx={{ color: '#697386' }}>Add-ons Surcharge</Typography>
                      <Typography variant="body2" sx={{ fontWeight: 600 }}>+${addOnsCost.toFixed(2)}</Typography>
                    </Box>
                  )}

                  {customRoomsPrice > 0 && (
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2" sx={{ color: '#697386' }}>Custom Rooms Premium</Typography>
                      <Typography variant="body2" sx={{ fontWeight: 600 }}>+${customRoomsPrice.toFixed(2)}</Typography>
                    </Box>
                  )}

                  {booking.promo_code && (
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2" sx={{ color: '#635bff', fontWeight: 600 }}>Promo Code: {booking.promo_code}</Typography>
                      <Typography variant="body2" sx={{ color: '#ff5f5f', fontWeight: 600 }}>-${discount > 0 ? discount.toFixed(2) : '0.00'}</Typography>
                    </Box>
                  )}

                  <Divider sx={{ my: 1 }} />

                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="subtitle1" sx={{ fontWeight: 700, color: '#0A2540' }}>Net Payable Amount</Typography>
                    <Typography variant="h5" sx={{ fontWeight: 800, color: '#00d4b6' }}>
                      ${finalPrice.toFixed(2)}
                    </Typography>
                  </Box>
                </Stack>
              </Box>

              {/* Notes */}
              {booking.notes && (
                <Box>
                  <Typography variant="subtitle2" sx={{ color: '#697386', fontWeight: 700, mb: 1, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: '0.72rem' }}>
                    SPECIAL INSTRUCTIONS / NOTES
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 1, p: 2, bgcolor: '#fff', border: '1px solid #e6ebf1', borderRadius: '8px' }}>
                    <NotesOutlined sx={{ color: '#a3b1c2', mt: 0.2 }} />
                    <Typography variant="body2" sx={{ color: '#424e5e', whiteSpace: 'pre-line' }}>
                      {booking.notes}
                    </Typography>
                  </Box>
                </Box>
              )}
            </Stack>
          </Grid>
        </Grid>
      </DialogContent>
      <Divider />

      <DialogActions sx={{ p: 2.5, gap: 1.5 }}>
        <Button onClick={onClose} variant="outlined" sx={{ textTransform: 'none', borderColor: '#e6ebf1', color: '#0A2540' }}>
          Dismiss
        </Button>

        {booking.status === 'pending' && (
          <>
            <Button
              onClick={() => onCancel(booking.id)}
              color="error"
              variant="outlined"
              sx={{ textTransform: 'none' }}
            >
              Reject Booking
            </Button>
            <Button
              onClick={() => onAccept(booking.id)}
              variant="contained"
              startIcon={<CheckCircleOutlined />}
              sx={{ bgcolor: '#635bff', textTransform: 'none', boxShadow: 'none', '&:hover': { bgcolor: '#0A2540' } }}
            >
              Approve & Accept
            </Button>
          </>
        )}

        {booking.status === 'accepted' && (
          <>
            <Button
              onClick={() => onCancel(booking.id)}
              color="error"
              variant="outlined"
              sx={{ textTransform: 'none' }}
            >
              Cancel Booking
            </Button>
            <Button
              onClick={() => onComplete(booking.id)}
              variant="contained"
              sx={{ bgcolor: '#00d4b6', textTransform: 'none', boxShadow: 'none', '&:hover': { bgcolor: '#00bda2' } }}
            >
              Mark Completed
            </Button>
          </>
        )}
      </DialogActions>
    </Dialog>
  );
};

export default BookingDetails;
