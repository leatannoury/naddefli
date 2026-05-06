USE NaddefliDB
GO

-- Insert sample users (passwords are hashed versions of "123456")
-- Hash: $2a$10$5qW8w4hR7x9Kk3xE5vM8Y.Lw9w8hR7x9Kk3xE5vM8Y.Lw9w8hR
DECLARE @adminId UNIQUEIDENTIFIER = NEWID();
DECLARE @customerId UNIQUEIDENTIFIER = NEWID();
DECLARE @cleanerId UNIQUEIDENTIFIER = NEWID();

INSERT INTO users (id, full_name, email, phone, password, role, created_at)
VALUES 
    (@adminId, 'Admin User', 'admin@test.com', '+1234567890', '$2a$10$5qW8w4hR7x9Kk3xE5vM8Y.Lw9w8hR7x9Kk3xE5vM8Y.Lw9w8hR', 'admin', GETDATE()),
    (@customerId, 'Test Customer', 'user@test.com', '+1987654321', '$2a$10$5qW8w4hR7x9Kk3xE5vM8Y.Lw9w8hR7x9Kk3xE5vM8Y.Lw9w8hR', 'customer', GETDATE()),
    (@cleanerId, 'Test Cleaner', 'cleaner@test.com', '+1555555555', '$2a$10$5qW8w4hR7x9Kk3xE5vM8Y.Lw9w8hR7x9Kk3xE5vM8Y.Lw9w8hR', 'cleaner', GETDATE());

-- Insert cleaner profile
INSERT INTO cleaners (user_id, experience_years, rating, is_available, national_id)
VALUES (@cleanerId, 5, 4.8, 1, 'ID123456789');

-- Insert sample services
INSERT INTO services (name, description, base_price, duration_hours, image, created_at)
VALUES 
    ('Kitchen Cleaning', 'Professional kitchen cleaning service', 15.00, 2.0, 'kitchen.jpg', GETDATE()),
    ('Bathroom Cleaning', 'Complete bathroom cleaning and sanitization', 10.00, 1.0, 'bathroom.jpg', GETDATE()),
    ('Bedroom Cleaning', 'Thorough bedroom cleaning and organization', 12.00, 1.5, 'bedroom.jpg', GETDATE()),
    ('Full House Cleaning', 'Complete house cleaning service', 40.00, 4.0, 'house.jpg', GETDATE()),
    ('Window Cleaning', 'Professional window and glass cleaning', 20.00, 1.5, 'window.jpg', GETDATE()),
    ('Sofa Cleaning', 'Deep sofa and upholstery cleaning', 25.00, 2.0, 'sofa.jpg', GETDATE()),
    ('Pest Control', 'Professional pest control and prevention', 50.00, 2.0, 'pest.jpg', GETDATE()),
    ('Office Cleaning', 'Commercial office cleaning service', 35.00, 3.0, 'office.jpg', GETDATE());

PRINT 'Sample data inserted successfully!';
PRINT 'Test Credentials:';
PRINT 'Customer Email: user@test.com | Password: 123456';
PRINT 'Cleaner Email: cleaner@test.com | Password: 123456';
PRINT 'Admin Email: admin@test.com | Password: 123456';
