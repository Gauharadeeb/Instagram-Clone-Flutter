# Quick Start Guide - Instagram Home Feed

## Prerequisites
- Python 3.8+ installed
- Flutter SDK installed
- Django and Django REST Framework knowledge
- Flutter development experience

## Backend Setup

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Database
```bash
python manage.py makemigrations
python manage.py migrate
```

### 3. Create Test Data
```bash
python create_test_posts.py
```

This creates:
- 3 test users
- 15 test posts (5 per user)
- Sample images and captions

### 4. Start Django Server
```bash
python manage.py runserver
```

Server will run at: `http://localhost:8000`

### 5. Test API Endpoints

First, get a JWT token by logging in:
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser1", "password": "TestPass123!"}'
```

Save the `access` token from the response.

Test the feed endpoint:
```bash
curl -X GET http://localhost:8000/api/feed/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Frontend Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure API URL
Edit `lib/services/feed_api_service.dart` and `lib/services/auth_api_service.dart`:
```dart
final String baseUrl = 'http://localhost:8000';  // Update if needed
```

### 3. Run Flutter App
```bash
flutter run
```

### 4. Test the App
1. **Login Screen**: Use test credentials
   - Username: `testuser1`
   - Password: `TestPass123!`

2. **Home Feed**: 
   - Verify posts load automatically
   - Check images display correctly
   - Verify like button functionality
   - Test pull-to-refresh

3. **Error Handling**:
   - Stop Django server
   - Try to refresh feed
   - Should show error message
   - Restart server and retry

## Common Issues

### Backend Issues

**Issue**: ModuleNotFoundError for Django REST Framework
```bash
pip install djangorestframework djangorestframework-simplejwt django-cors-headers
```

**Issue**: Permission denied for media folder
```bash
# Create media directory manually
mkdir -p backend/media/post_images
```

**Issue**: CORS errors
- Ensure `django-cors-headers` is installed
- Check `CORS_ALLOWED_ORIGINS` in settings.py

### Frontend Issues

**Issue**: Network error on emulator
- Use `10.0.2.2:8000` instead of `localhost:8000` for Android emulator
- Use `localhost:8000` for iOS simulator

**Issue**: Images not loading
- Check Django server is running
- Verify media files are accessible at `/media/`
- Check image URLs in API response

**Issue**: Authentication errors
- Verify JWT token is valid
- Check token expiration (default 60 minutes)
- Ensure `Authorization` header format: `Bearer <token>`

## Testing Checklist

### Backend Testing
- [ ] Server starts without errors
- [ ] Migrations run successfully
- [ ] Test data created (15 posts)
- [ ] Feed endpoint returns posts
- [ ] Like endpoint updates counts
- [ ] JWT authentication works
- [ ] Media files accessible

### Frontend Testing
- [ ] App compiles without errors
- [ ] Login works with test credentials
- [ ] Feed loads on screen open
- [ ] Posts display in correct order
- [ ] Images load with loading states
- [ ] Like button updates counts
- [ ] Pull-to-refresh works
- [ ] Error states display correctly
- [ ] UI is responsive

## API Endpoints Reference

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/create-account/` - User registration

### Feed
- `GET /api/feed/` - Get all posts (JWT protected)
- `POST /api/posts/<id>/like/` - Like/unlike post (JWT protected)
- `GET /api/posts/<id>/` - Get single post (JWT protected)

### Response Format

**Feed Response:**
```json
[
  {
    "id": 1,
    "user": {
      "id": 1,
      "username": "testuser1",
      "email": "test1@example.com",
      "first_name": "",
      "last_name": ""
    },
    "image": "post_images/test_image.jpg",
    "image_url": "http://localhost:8000/media/post_images/test_image.jpg",
    "caption": "Beautiful sunset today! 🌅",
    "likes_count": 0,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

**Like Response:**
```json
{
  "status": "success",
  "likes_count": 1,
  "action": "like"
}
```

## Performance Tips

### Backend
- Use pagination for large feeds (not implemented yet)
- Add database indexes on frequently queried fields
- Implement caching for feed data
- Use CDN for media files in production

### Frontend
- Implement image caching
- Add lazy loading for posts
- Optimize image sizes
- Use pagination instead of loading all posts

## Development Tips

1. **Hot Reload**: Use Flutter's hot reload during development
2. **Debug Mode**: Run Django in debug mode for detailed error messages
3. **Logging**: Add print statements for debugging API calls
4. **Database Inspection**: Use Django admin to inspect data
5. **API Testing**: Use Postman or curl for API testing

## Production Considerations

- Use environment variables for configuration
- Implement proper logging
- Add rate limiting
- Use HTTPS in production
- Implement proper error logging
- Add monitoring and analytics
- Use production database (PostgreSQL recommended)
- Configure proper CORS settings
- Implement file compression for images

## Support

For issues or questions:
1. Check the main implementation document: `HOME_FEED_IMPLEMENTATION.md`
2. Review Django REST Framework documentation
3. Check Flutter Provider package documentation
4. Review error messages carefully
5. Test API endpoints independently
