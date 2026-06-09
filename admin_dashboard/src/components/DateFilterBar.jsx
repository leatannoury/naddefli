/**
 * NADDEFLI — DateFilterBar.jsx
 * Layer: Admin — Component
 * Purpose: Date range picker for filtering booking/customer lists.
 * Connects to: Bookings, Dashboard pages
 */

import React from 'react';
import { Box, Button, TextField, FormControl, InputLabel, Select, MenuItem, Chip, Stack } from '@mui/material';
import { Today, DateRange, AllInclusive } from '@mui/icons-material';

const todayStr = () => new Date().toISOString().split('T')[0];

const DateFilterBar = ({
  filterMode,
  startDate,
  endDate,
  timeframe = 'day',
  onFilterModeChange,
  onStartDateChange,
  onEndDateChange,
  onTimeframeChange,
  showTimeframe = false,
  showAllTime = true,
}) => {
  const periodLabel =
    filterMode === 'today'
      ? 'Today'
      : filterMode === 'all'
        ? 'All time'
        : startDate && endDate
          ? `${new Date(startDate).toLocaleDateString()} – ${new Date(endDate).toLocaleDateString()}`
          : 'Custom range';

  return (
    <Box
      sx={{
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        gap: 1.5,
        p: 2,
        borderRadius: '12px',
        border: '1px solid #e6ebf1',
        bgcolor: '#fff',
      }}
    >
      <Chip label={periodLabel} size="small" sx={{ fontWeight: 700, bgcolor: '#635bff14', color: '#635bff' }} />

      <Stack direction="row" spacing={1}>
        <Button
          size="small"
          variant={filterMode === 'today' ? 'contained' : 'outlined'}
          startIcon={<Today />}
          onClick={() => onFilterModeChange('today')}
          sx={{ textTransform: 'none', boxShadow: 'none' }}
        >
          Today
        </Button>
        {showAllTime && (
          <Button
            size="small"
            variant={filterMode === 'all' ? 'contained' : 'outlined'}
            startIcon={<AllInclusive />}
            onClick={() => onFilterModeChange('all')}
            sx={{ textTransform: 'none', boxShadow: 'none' }}
          >
            All time
          </Button>
        )}
        <Button
          size="small"
          variant={filterMode === 'range' ? 'contained' : 'outlined'}
          startIcon={<DateRange />}
          onClick={() => onFilterModeChange('range')}
          sx={{ textTransform: 'none', boxShadow: 'none' }}
        >
          Date range
        </Button>
      </Stack>

      {filterMode === 'range' && (
        <>
          <TextField
            label="From"
            type="date"
            size="small"
            value={startDate}
            onChange={(e) => onStartDateChange(e.target.value)}
            InputLabelProps={{ shrink: true }}
            sx={{ width: 150 }}
          />
          <TextField
            label="To"
            type="date"
            size="small"
            value={endDate}
            onChange={(e) => onEndDateChange(e.target.value)}
            InputLabelProps={{ shrink: true }}
            sx={{ width: 150 }}
            disabled={filterMode === 'today'}
          />
        </>
      )}

      {showTimeframe && filterMode === 'all' && (
        <FormControl size="small" sx={{ minWidth: 160 }}>
          <InputLabel>Chart grouping</InputLabel>
          <Select
            label="Chart grouping"
            value={timeframe}
            onChange={(e) => onTimeframeChange(e.target.value)}
          >
            <MenuItem value="day">By day (30 days)</MenuItem>
            <MenuItem value="month">By month (12 mo)</MenuItem>
            <MenuItem value="year">By year (5 yr)</MenuItem>
          </Select>
        </FormControl>
      )}
    </Box>
  );
};

export { todayStr };
export default DateFilterBar;
