USE master
GO

-- Enable Shared Memory
EXEC xp_regwrite 
  @rootkey='HKEY_LOCAL_MACHINE',
  @key='Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Sm',
  @value_name='Enabled',
  @type='REG_DWORD',
  @value=1
GO
