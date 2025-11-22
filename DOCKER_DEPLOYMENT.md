# Fitness Tracker - Docker Deployment Guide

## Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** v2.0+
- **8GB+ RAM** available for containers
- **Gemini API Key** from Google AI Studio

---

## Quick Start

### 1. Setup Environment Variables

Copy the example environment file:

```powershell
Copy-Item .env.example .env
```

Edit `.env` and add your Gemini API key:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 2. Build and Start All Services

```powershell
docker-compose up --build
```

**Startup time**: ~5-10 minutes (services start sequentially with health checks)

### 3. Verify Services

Check all containers are running:

```powershell
docker-compose ps
```

All services should show `healthy` status.

---

## Service Endpoints

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Use Keycloak login |
| **API Gateway** | http://localhost:8080 | JWT required |
| **Eureka Dashboard** | http://localhost:8761 | None |
| **Config Server** | http://localhost:8888 | None |
| **Keycloak Admin** | http://localhost:8181 | admin/admin |
| **RabbitMQ Management** | http://localhost:15672 | guest/guest |
| **User Service** | http://localhost:8081 | Via Gateway |
| **Activity Service** | http://localhost:8082 | Via Gateway |
| **AI Service** | http://localhost:8083 | Via Gateway |

---

## Keycloak Configuration (First Time Setup)

### 1. Access Keycloak Admin Console
- Navigate to http://localhost:8181
- Login with `admin/admin`

### 2. Create Realm
1. Click **Create Realm**
2. Name: `fitness-oauth2`
3. Click **Create**

### 3. Create Client
1. Go to **Clients** → **Create client**
2. **General Settings**:
   - Client ID: `fitness-app`
   - Client Protocol: `openid-connect`
   - Click **Next**
3. **Capability Config**:
   - Client authentication: OFF (public client)
   - Authorization: OFF
   - Standard flow: ✅ ON
   - Direct access grants: ✅ ON
   - Click **Next**
4. **Login Settings**:
   - Root URL: `http://localhost:3000`
   - Valid redirect URIs: 
     - `http://localhost:3000/*`
     - `http://localhost:5173/*` (for local dev)
   - Valid post logout redirect URIs: `http://localhost:3000/*`
   - Web origins: `+` (allow CORS for all valid redirect URIs)
   - Click **Save**

### 4. Create Test User
1. Go to **Users** → **Create user**
2. Fill in:
   - Username: `testuser`
   - Email: `test@example.com`
   - First Name: `Test`
   - Last Name: `User`
   - Email Verified: ✅ ON
   - Click **Create**
3. Set Password:
   - Go to **Credentials** tab
   - Click **Set password**
   - Password: `password` (or your choice)
   - Temporary: OFF
   - Click **Save**

---

## Testing the Application

### 1. Open Frontend
Navigate to http://localhost:3000

### 2. Login
Click **Log in to Continue** → redirects to Keycloak → login with `testuser/password`

### 3. Create Activity
1. Fill in the activity form:
   - Type: RUNNING
   - Duration: 30
   - Calories: 300
   - Start Time: (current time)
2. Submit

### 4. View AI Recommendations
Click on the activity to see AI-generated recommendations (processed via RabbitMQ)

---

## Troubleshooting

### Services not starting
```powershell
# Check logs for specific service
docker-compose logs -f [service-name]

# Example: Check API Gateway logs
docker-compose logs -f api-gateway
```

### Database connection errors
```powershell
# Restart databases
docker-compose restart postgres mongodb-activity mongodb-ai
```

### Keycloak realm not found error
- Ensure you created the `fitness-oauth2` realm in Keycloak admin console
- Update API Gateway config if realm name differs

### RabbitMQ connection refused
```powershell
# Check RabbitMQ is healthy
docker-compose ps rabbitmq

# View RabbitMQ logs
docker-compose logs -f rabbitmq
```

### Frontend can't reach API Gateway
- Check CORS configuration in `api-gateway` SecurityConfig
- Verify frontend is using correct API URL in `axios.js`

---

## Managing Containers

### Stop all services
```powershell
docker-compose down
```

### Stop and remove volumes (clean state)
```powershell
docker-compose down -v
```

### Restart specific service
```powershell
docker-compose restart [service-name]
```

### Rebuild after code changes
```powershell
docker-compose up --build [service-name]
```

### View real-time logs
```powershell
docker-compose logs -f
```

---

## Development Workflow

### Making Code Changes

1. **Stop the service**:
   ```powershell
   docker-compose stop [service-name]
   ```

2. **Rebuild the service**:
   ```powershell
   docker-compose build [service-name]
   ```

3. **Start the service**:
   ```powershell
   docker-compose up -d [service-name]
   ```

### Hot Reload (Development Mode)

For local development without Docker:
```powershell
# Start infrastructure only
docker-compose up postgres mongodb-activity mongodb-ai rabbitmq keycloak

# Run services locally in IDE
```

---

## Port Reference

| Port | Service |
|------|---------|
| 3000 | Frontend (Nginx) |
| 5432 | PostgreSQL |
| 8080 | API Gateway |
| 8081 | User Service |
| 8082 | Activity Service |
| 8083 | AI Service |
| 8181 | Keycloak |
| 8761 | Eureka Server |
| 8888 | Config Server |
| 15672 | RabbitMQ Management UI |
| 27017 | MongoDB Activity |
| 27018 | MongoDB AI (mapped to 27017 internally) |

---

## Health Checks

Check service health:

```powershell
# Eureka
curl http://localhost:8761/actuator/health

# Config Server
curl http://localhost:8888/actuator/health

# User Service
curl http://localhost:8081/actuator/health

# Activity Service
curl http://localhost:8082/actuator/health

# AI Service
curl http://localhost:8083/actuator/health

# API Gateway
curl http://localhost:8080/actuator/health
```

---

## Next Steps

After successful local deployment:
1. ✅ Test all features (create user, log activities, view recommendations)
2. 🔧 Configure CI/CD pipeline (Jenkins)
3. ☁️ Deploy to AWS EKS
4. 📊 Add monitoring (Prometheus/Grafana)
5. 🔒 Implement production security hardening
