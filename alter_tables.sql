-- Update bookings table with new columns for custom requests
USE NaddefliDB
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'is_custom')
BEGIN
    ALTER TABLE bookings ADD is_custom BIT DEFAULT 0;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'property_type')
BEGIN
    ALTER TABLE bookings ADD property_type NVARCHAR(50);
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'room_count')
BEGIN
    ALTER TABLE bookings ADD room_count INT DEFAULT 0;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'bathrooms_count')
BEGIN
    ALTER TABLE bookings ADD bathrooms_count INT DEFAULT 0;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'kitchens_count')
BEGIN
    ALTER TABLE bookings ADD kitchens_count INT DEFAULT 0;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'cleaning_type')
BEGIN
    ALTER TABLE bookings ADD cleaning_type NVARCHAR(50) DEFAULT 'normal';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('bookings') AND name = 'extras')
BEGIN
    ALTER TABLE bookings ADD extras NVARCHAR(MAX);
END

PRINT 'Bookings table updated successfully!';
GO
