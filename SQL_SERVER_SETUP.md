# SQL Server Setup Guide for Naddefli

This guide helps you set up Microsoft SQL Server for Naddefli backend.

## 🗄️ Prerequisites

- Microsoft SQL Server installed (Express, Standard, or Enterprise)
- SQL Server Management Studio (SSMS)
- SQL Server TCP/IP enabled

## 📋 SQL Server Installation

### Windows

1. **Download SQL Server**
   - [SQL Server 2022 Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
   - [SQL Server 2019](https://www.microsoft.com/en-us/sql-server/sql-server-2019)

2. **Run Installer**
   - Choose "Custom" installation
   - Select Engine Services
   - Select Tools (SSMS)

3. **Configuration**
   - Instance Name: SQLEXPRESS (or custom)
   - Authentication Mode: Mixed Mode (SQL & Windows)
   - SA Password: Choose strong password
   - TCP/IP: Enable in SQL Server Configuration Manager

### Docker (Recommended)

```bash
# Pull SQL Server image
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Run container
docker run -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=YourPassword@123' \
  -p 1433:1433 \
  --name naddefli_db \
  mcr.microsoft.com/mssql/server:2022-latest
```

## 🔗 Connection Setup

### SQL Server Management Studio (SSMS)

1. **Download SSMS**: [Download Link](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

2. **Connect to Server**
   - Open SSMS
   - Server name: `localhost,1433` or `localhost\SQLEXPRESS`
   - Authentication: SQL Server Authentication
   - Login: `sa`
   - Password: (your SA password)
   - Click Connect

3. **Create Login (Optional)**
   ```sql
   USE master
   GO
   CREATE LOGIN naddefli_user WITH PASSWORD = 'SecurePassword@123'
   GO
   ```

## 🏗️ Database Creation

### Option 1: Manual Creation in SSMS

1. Right-click "Databases" → New Database
2. Database name: `NaddefliDB`
3. Click OK

### Option 2: Using SQL Command

```sql
CREATE DATABASE NaddefliDB
GO
```

### Option 3: Automatic (via Application)

The Node.js app automatically creates the database if it doesn't exist.

## 📊 Initial Setup

### Create Database User

```sql
USE master
GO
CREATE LOGIN naddefli_user WITH PASSWORD = 'StrongPassword@123'
GO

USE NaddefliDB
GO
CREATE USER naddefli_user FOR LOGIN naddefli_user
GO

-- Grant permissions
ALTER ROLE db_owner ADD MEMBER naddefli_user
GO
```

## ⚙️ Configuration

### TCP/IP Enablement

1. Open SQL Server Configuration Manager
2. Navigate to: SQL Server Network Configuration → Protocols for SQLEXPRESS
3. Right-click "TCP/IP" → Enable
4. Restart SQL Server

### Firewall Rules

Allow SQL Server through Windows Firewall:

```powershell
# PowerShell (Admin)
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=tcp localport=1433 profile=any
```

## 🔐 Environment Configuration

### .env File Setup

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=NaddefliDB
DB_USER=sa
DB_PASSWORD=YourPassword@123

# Or using created user:
DB_USER=naddefli_user
DB_PASSWORD=StrongPassword@123
```

## ✅ Verification

### Test Connection via Command Line

```bash
# Windows
sqlcmd -S localhost -U sa -P "YourPassword@123"

# If connected successfully, you'll see:
1>
```

### Test from Node.js

```javascript
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('NaddefliDB', 'sa', 'YourPassword@123', {
  host: 'localhost',
  port: 1433,
  dialect: 'mssql',
  logging: false,
  dialectOptions: {
    options: {
      requestTimeout: 30000,
      encrypt: false,
      trustServerCertificate: true,
    },
  },
});

sequelize
  .authenticate()
  .then(() => console.log('✅ Connection successful'))
  .catch(err => console.error('❌ Connection failed:', err));
```

## 🚀 Running Migrations

### First Time Setup

```bash
# Navigate to backend
cd backend_node

# Run migrations (creates tables)
npm run migrate

# Seed sample data
npm run seed
```

### Verify Tables Created

In SSMS:
1. Expand NaddefliDB → Tables
2. Should see:
   - users
   - cleaners
   - services
   - bookings
   - reviews
   - notifications

## 📈 Database Monitoring

### Check Database Size

```sql
USE NaddefliDB
GO
SELECT 
  name,
  size * 8 / 1024 AS Size_MB
FROM sys.database_files
```

### View Active Connections

```sql
SELECT
  session_id,
  login_name,
  status,
  host_name,
  database_id
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('NaddefliDB')
```

### Kill Connections (if needed)

```sql
USE master
GO
ALTER DATABASE NaddefliDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE NaddefliDB SET MULTI_USER
```

## 🔄 Backup & Restore

### Create Backup

```sql
BACKUP DATABASE NaddefliDB
TO DISK = 'C:\Backups\NaddefliDB.bak'
GO
```

### Restore from Backup

```sql
RESTORE DATABASE NaddefliDB
FROM DISK = 'C:\Backups\NaddefliDB.bak'
GO
```

## 🐛 Troubleshooting

### Connection Refused
```
Error: ECONNREFUSED

Solution:
1. Verify SQL Server service is running
   - Services.msc → SQL Server (SQLEXPRESS)
2. Check TCP/IP is enabled
3. Verify firewall allows port 1433
4. Check host/port in .env
```

### Authentication Failed
```
Error: Login failed for user 'sa'

Solution:
1. Verify password in .env
2. Ensure Mixed Mode authentication enabled
3. Check username spelling
4. Reset SA password if forgotten
```

### Timeout Error
```
Error: Request timeout

Solution:
1. Increase timeout in .env
2. Check network connectivity
3. Verify database server is responding
4. Check for heavy queries
```

### Database Already Exists
```
If NaddefliDB already exists and you want fresh start:

USE master
GO
DROP DATABASE NaddefliDB
GO

Then run: npm run migrate && npm run seed
```

## 📚 Useful SQL Commands

### View All Databases
```sql
SELECT name FROM sys.databases
```

### View All Tables
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo'
```

### View Table Structure
```sql
EXEC sp_help 'dbo.users'
```

### Count Records
```sql
SELECT COUNT(*) FROM users
SELECT COUNT(*) FROM bookings
SELECT COUNT(*) FROM services
```

### Reset Auto-Increment
```sql
DBCC CHECKIDENT (tablename, RESEED, 0)
```

## 🔐 Security Best Practices

✅ Use strong SA password  
✅ Create limited user instead of SA  
✅ Enable authentication  
✅ Disable unnecessary protocols  
✅ Regular backups  
✅ Monitor access logs  
✅ Use encryption in production  

## 📞 Support

### Common Issues

**Q: Port 1433 already in use**  
A: Change port in SQL Server Configuration or kill process using port

**Q: SSMS won't connect**  
A: Restart SQL Server service in Services.msc

**Q: Migrations fail**  
A: Ensure database exists and user has permissions

**Q: Wrong collation**  
A: Recreate database with: `COLLATE SQL_Latin1_General_CP1_CI_AS`

## 🎯 Next Steps

1. ✅ SQL Server installed
2. ✅ Database created
3. ✅ User configured
4. ✅ Connection verified
5. → Run backend migrations
6. → Seed sample data
7. → Start API server

---

**Version**: 1.0  
**Last Updated**: April 2024
