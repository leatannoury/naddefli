const BASE_URL = 'http://localhost:5000/api';

async function runTests() {
  console.log('🚀 Starting Naddefli Admin E2E Verification Tests...');
  let token = null;

  try {
    // Helper function for fetching with JSON handling and status checking
    async function apiRequest(endpoint, options = {}) {
      const url = `${BASE_URL}${endpoint}`;
      const headers = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...(options.headers || {})
      };
      
      const response = await fetch(url, {
        ...options,
        headers,
        body: options.body ? JSON.stringify(options.body) : undefined
      });

      const data = await response.json();
      
      if (!response.ok) {
        const err = new Error(data.message || `Request failed with status ${response.status}`);
        err.status = response.status;
        err.data = data;
        throw err;
      }
      
      return data;
    }

    // 1. Test Admin Login
    console.log('\n--- 1. Testing Admin Login ---');
    const loginRes = await apiRequest('/admin/login', {
      method: 'POST',
      body: {
        email: 'admin@test.com',
        password: '123456'
      }
    });

    if (loginRes.success && loginRes.data.token) {
      token = loginRes.data.token;
      console.log('✅ Admin Login Successful!');
      console.log('Role:', loginRes.data.user.role);
      console.log('Email:', loginRes.data.user.email);
    } else {
      throw new Error('Admin login response did not contain token');
    }

    // 2. Fetch Dashboard Statistics
    console.log('\n--- 2. Fetching Dashboard Statistics ---');
    const statsRes = await apiRequest('/admin/dashboard');
    if (statsRes.success) {
      console.log('✅ Dashboard Stats Fetched Successfully!');
      console.log('Stats:', statsRes.data.stats);
    } else {
      throw new Error('Failed to fetch dashboard stats');
    }

    // 3. Fetch Bookings List
    console.log('\n--- 3. Fetching Bookings List ---');
    const bookingsRes = await apiRequest('/admin/bookings');
    if (bookingsRes.success) {
      console.log('✅ Bookings List Fetched Successfully!');
      console.log('Bookings Count:', bookingsRes.data.length);
    } else {
      throw new Error('Failed to fetch bookings list');
    }

    // 4. Fetch Customers List
    console.log('\n--- 4. Fetching Customers List ---');
    const customersRes = await apiRequest('/admin/customers');
    let targetCustomer = null;
    if (customersRes.success) {
      console.log('✅ Customers List Fetched Successfully!');
      console.log('Customers Count:', customersRes.data.length);
      targetCustomer = customersRes.data.find(c => c.email === 'user@test.com');
      if (targetCustomer) {
        console.log('Found test customer:', targetCustomer.full_name, 'Blocked:', targetCustomer.is_blocked);
      }
    } else {
      throw new Error('Failed to fetch customers list');
    }

    // 5. Test Customer Block/Unblock
    if (targetCustomer) {
      console.log('\n--- 5. Testing Customer Blocking & Unblocking ---');
      
      // Block
      console.log(`Blocking customer ${targetCustomer.full_name}...`);
      const blockRes = await apiRequest(`/admin/customers/${targetCustomer.id}/block`, {
        method: 'PUT',
        body: { is_blocked: true }
      });
      if (blockRes.success) {
        console.log('✅ Customer blocked successfully!');
      } else {
        throw new Error('Failed to block customer');
      }

      // Verify blocked user login fails
      console.log('Verifying blocked customer login fails...');
      try {
        await apiRequest('/auth/login', {
          method: 'POST',
          body: {
            email: 'user@test.com',
            password: '123456'
          }
        });
        throw new Error('Login should have failed for blocked user but succeeded');
      } catch (err) {
        if (err.status === 403) {
          console.log('✅ Blocked user login successfully rejected with 403 Forbidden!');
        } else {
          throw err;
        }
      }

      // Unblock
      console.log(`Unblocking customer ${targetCustomer.full_name}...`);
      const unblockRes = await apiRequest(`/admin/customers/${targetCustomer.id}/block`, {
        method: 'PUT',
        body: { is_blocked: false }
      });
      if (unblockRes.success) {
        console.log('✅ Customer unblocked successfully!');
      } else {
        throw new Error('Failed to unblock customer');
      }

      // Verify login works again
      console.log('Verifying customer login works again...');
      const userLoginRes = await apiRequest('/auth/login', {
        method: 'POST',
        body: {
          email: 'user@test.com',
          password: '123456'
        }
      });
      if (userLoginRes.success) {
        console.log('✅ Customer login works successfully after unblock!');
      } else {
        throw new Error('Customer login failed after unblock');
      }
    }

    // 6. Fetch Services List
    console.log('\n--- 6. Fetching Services List ---');
    const servicesRes = await apiRequest('/admin/services');
    if (servicesRes.success) {
      console.log('✅ Services List Fetched Successfully!');
      console.log('Services Count:', servicesRes.data.length);
    } else {
      throw new Error('Failed to fetch services list');
    }

    // 7. Fetch Promos List
    console.log('\n--- 7. Fetching Promos List ---');
    const promosRes = await apiRequest('/admin/promos');
    if (promosRes.success) {
      console.log('✅ Promos List Fetched Successfully!');
      console.log('Promos Count:', promosRes.data.length);
    } else {
      throw new Error('Failed to fetch promos list');
    }

    // 8. Create a New Promo Code
    console.log('\n--- 8. Creating a New Promo Campaign ---');
    const newPromo = {
      code: 'E2ETEST' + Math.floor(Math.random() * 100),
      type: 'percentage',
      value: 15.0,
      conditions: 'Test Campaign',
      expires_at: new Date('2030-12-31').toISOString(),
      is_active: true
    };
    const createPromoRes = await apiRequest('/admin/promos', {
      method: 'POST',
      body: newPromo
    });
    if (createPromoRes.success) {
      console.log('✅ Promo Code Created Successfully:', createPromoRes.data.code);
    } else {
      throw new Error('Failed to create promo code');
    }

    // 9. Fetch Settings
    console.log('\n--- 9. Fetching Settings ---');
    const settingsRes = await apiRequest('/admin/settings');
    if (settingsRes.success) {
      console.log('✅ System Settings Fetched Successfully!');
      console.log('Settings:', settingsRes.data);
    } else {
      throw new Error('Failed to fetch settings');
    }

    console.log('\n🌟 ALL E2E VERIFICATION TESTS PASSED SUCCESSFULLY! 🌟');
  } catch (error) {
    console.error('\n❌ E2E VERIFICATION TEST FAILED:', error.message);
    if (error.status) {
      console.error('Response Status:', error.status);
      console.error('Response Data:', error.data);
    }
  }
}

runTests();
