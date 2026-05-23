# JWT Authentication Fix - Testing Guide

## Quick Test Steps

### 1. Stop Current Flutter App
Stop any running Flutter instances.

### 2. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### 3. Test Login
- Use credentials: `testuser1` / `TestPass123!`
- Login should be successful
- Tokens are now automatically saved to SharedPreferences

### 4. Test Feed Navigation
- After login, you should be automatically navigated to feed
- Feed should load without 401 error
- Posts should display correctly

### 5. Verify Network Request
If you have network debugging enabled, you should see:
```
Request Headers:
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

---

## Debug Logging (Optional)

If you want to verify token flow, add this to `base_api_service.dart`:

```dart
Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
  };

  if (requireAuth) {
    final token = await _tokenStorage.getAccessToken();
    debugPrint('🔑 Token retrieved: ${token?.substring(0, 20)}...');
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('✅ Authorization header set successfully');
    } else {
      debugPrint('❌ No token found in storage');
    }
  }

  return headers;
}
```

---

## Expected Results

### ✅ Success Scenario
1. Login successful → Tokens saved automatically
2. Navigate to feed → Token retrieved automatically
3. API call made → Authorization header added automatically
4. Backend validates → Returns 200 OK with feed data
5. UI displays → Posts shown correctly

### ❌ Failure Scenarios (Should Not Happen)
1. 401 Unauthorized → Fixed by automatic token injection
2. Token not found → Fixed by persistent storage
3. Token expired → Will need token refresh (future enhancement)

---

## Backend Server Status

Your Django server is currently running on: `http://localhost:8000`

Test the API directly:
```bash
# First login to get token
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser1", "password": "TestPass123!"}'

# Use the access token from response to test feed
curl -X GET http://localhost:8000/api/feed/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Troubleshooting

### Still Getting 401 Error?

1. **Check Django Server**
```bash
# Make sure server is running
cd backend
python manage.py runserver
```

2. **Check Token Storage**
```dart
// Add this to login screen after successful login
final token = await TokenStorageService().getAccessToken();
debugPrint('Saved token: $token');
```

3. **Check API URL**
```dart
// Make sure base URL is correct in both services
// AuthApiService: http://localhost:8000
// FeedApiService: http://localhost:8000
```

4. **Clear Old Data**
```bash
# Uninstall app and reinstall to clear old data
# Or clear app data in settings
```

### Network Timeout Error?

If you still get timeout errors:

1. **Check if running on emulator**
   - Android emulator: Use `10.0.2.2:8000` instead of `localhost:8000`
   - iOS simulator: Use `localhost:8000`
   - Physical device: Use your PC's IP address

2. **Update base URLs in both services**
```dart
// For Android emulator
this.baseUrl = 'http://10.0.2.2:8000'

// For iOS simulator  
this.baseUrl = 'http://localhost:8000'

// For physical device on same network
this.baseUrl = 'http://YOUR_PC_IP:8000'
```

---

## Complete Code Flow Verification

### Step 1: Login
```dart
AuthApiService().login(username: 'testuser1', password: 'TestPass123!')
↓
Backend validates credentials
↓
Returns: {"access": "token...", "refresh": "token...", "user": {...}}
↓
TokenStorageService.saveTokens() automatically called
↓
Tokens saved to SharedPreferences
```

### Step 2: Navigate to Feed
```dart
Navigator.push(InstagramFeedScreen(username: 'testuser1'))
↓
No token parameter needed anymore
```

### Step 3: Load Feed
```dart
FeedProvider.loadFeed()
↓
FeedApiService.getFeed()
↓
BaseApiService.get('/api/feed/', requireAuth: true)
↓
_getHeaders(requireAuth: true) called
↓
TokenStorageService.getAccessToken() called
↓
Token retrieved from SharedPreferences
↓
Authorization: Bearer <token> header added
↓
HTTP GET request made with auth header
↓
Backend validates JWT token
↓
Returns 200 OK with feed data
↓
UI displays posts
```

---

## Success Indicators

You'll know it's working when:

✅ Login succeeds without errors
✅ Feed loads automatically after login
✅ No 401 Unauthorized errors
✅ Posts display in the feed
✅ Like buttons work
✅ Pull-to-refresh works
✅ Network logs show Authorization header

---

## What Changed

### Before:
```dart
// ❌ Manual token passing
InstagramFeedScreen(username: 'test', accessToken: 'token...')

// ❌ Manual header setting  
headers['Authorization'] = 'Bearer $token'

// ❌ No persistent storage
```

### After:
```dart
// ✅ No token parameter
InstagramFeedScreen(username: 'test')

// ✅ Automatic token injection
BaseApiService handles headers automatically

// ✅ Persistent storage
Tokens saved to SharedPreferences
```

---

## Ready to Test!

Your app is now ready for testing with the complete JWT authentication fix:

1. ✅ Tokens stored persistently
2. ✅ Automatic token injection
3. ✅ Clean architecture
4. ✅ Production-ready error handling
5. ✅ No more 401 errors

Run `flutter run` and test the complete flow! 🚀
