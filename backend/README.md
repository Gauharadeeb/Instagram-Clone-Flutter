# Instagram Clone Backend

Django backend for the Flutter login and create-account screens.

## Setup

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

The API runs at `http://127.0.0.1:8000/api/auth/`.

## Endpoints

- `POST /api/auth/signup/`
- `POST /api/auth/create-account/`
- `POST /api/auth/login/`
- `GET /api/auth/me/`

Signup and create-account accept:

```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "StrongPass123"
}
```

Login accepts:

```json
{
  "username": "username",
  "password": "StrongPass123"
}
```

Successful auth responses include `access` and `refresh` JWT tokens plus user data.

For Android emulator testing, change the Flutter API base URL from `127.0.0.1` to `10.0.2.2`.
