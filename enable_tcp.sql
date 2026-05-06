USE master
GO

EXEC xp_regwrite 
  @rootkey='HKEY_LOCAL_MACHINE',
  @key='Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp',
  @value_name='Enabled',
  @type='REG_DWORD',
  @value=1
GO
