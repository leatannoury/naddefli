USE NaddefliDB
GO

-- Create users table
CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    full_name NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    phone NVARCHAR(20),
    password NVARCHAR(255) NOT NULL,
    role NVARCHAR(50) NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'cleaner', 'admin')),
    created_at DATETIME DEFAULT GETDATE()
);

-- Create cleaners table
CREATE TABLE cleaners (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    experience_years INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 5.0,
    is_available BIT DEFAULT 1,
    national_id NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create services table
CREATE TABLE services (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    base_price DECIMAL(10, 2) NOT NULL,
    duration_hours DECIMAL(5, 2) NOT NULL,
    image NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE()
);

-- Create bookings table
CREATE TABLE bookings (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    cleaner_id UNIQUEIDENTIFIER,
    service_id UNIQUEIDENTIFIER NOT NULL,
    booking_date DATETIME NOT NULL,
    booking_time NVARCHAR(5) NOT NULL,
    address NVARCHAR(MAX) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    notes NVARCHAR(MAX),
    total_price DECIMAL(10, 2) NOT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'on_the_way', 'started', 'completed', 'cancelled')),
    is_custom BIT DEFAULT 0,
    property_type NVARCHAR(50),
    room_count INT DEFAULT 0,
    bathrooms_count INT DEFAULT 0,
    kitchens_count INT DEFAULT 0,
    cleaning_type NVARCHAR(50) DEFAULT 'normal',
    extras NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (cleaner_id) REFERENCES cleaners(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);

-- Create reviews table
CREATE TABLE reviews (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    booking_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    cleaner_id UNIQUEIDENTIFIER NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (cleaner_id) REFERENCES cleaners(id)
);

-- Create notifications table
CREATE TABLE notifications (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    title NVARCHAR(255) NOT NULL,
    body NVARCHAR(MAX),
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

PRINT 'All tables created successfully!';
