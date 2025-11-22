# 🚀 Quick Start Guide - 5 Minutes to Running Application

## Prerequisites Check
- ✅ Docker Desktop running
- ✅ 8GB+ RAM available
- ✅ Ports available: 3000, 5432, 8080-8083, 8181, 8761, 8888, 15672, 27017-27018

---

## Step 1: Configure Environment (1 minute)

```powershell
# Edit .env file and add your Gemini API key
notepad .env
```

Replace `your_gemini_api_key_here` with your actual key from [Google AI Studio](https://makersuite.google.com/app/apikey)

---

## Step 2: Start Services (5-10 minutes)

```powershell
.\start.ps1
```

Wait for the script to complete. All services should show as healthy.

---

## Step 3: Configure Keycloak (2 minutes)

### Open Keycloak Admin Console
http://localhost:8181
- Username: `admin`
- Password: `admin`

### Create Realm
1. Click dropdown (top-left) → **Create Realm**
2. Realm name: `fitness-oauth2`
3. Click **Create**

### Create Client
1. **Clients** → **Create client**
2. **General Settings**:
   - Client ID: `fitness-app`
   - Click **Next**
3. **Capability config**:
   - Client authentication: **OFF**
   - Standard flow: **✅ ON**
   - Direct access grants: **✅ ON**
   - Click **Next**
4. **Login settings**:
   - Valid redirect URIs: `http://localhost:3000/*`
   - Valid post logout redirect URIs: `http://localhost:3000/*`
   - Web origins: `+`
   - Click **Save**

### Create User
1. **Users** → **Create user**
2. Fill in:
   - Username: `testuser`
   - Email: `test@example.com`
   - First name: `Test`
   - Last name: `User`
   - Email verified: **✅ ON**
   - Click **Create**
3. **Credentials** tab → **Set password**
   - Password: `password`
   - Temporary: **OFF**
   - Click **Save**

---

## Step 4: Test Application (2 minutes)

### Open Application
http://localhost:3000

### Login
1. Click **Log in to Continue**
2. Login with: `testuser` / `password`

### Create Activity
1. Fill in form:
   - Type: **RUNNING**
   - Duration: **30**
   - Calories: **300**
   - Start Time: (current date/time)
2. Click **Submit**

### View AI Recommendation
- Click on your activity card
- AI recommendation will appear (may take 10-20 seconds to process)

---

## Verify Services

### Check Dashboards
- **Eureka**: http://localhost:8761 (should show 5 registered services)
- **RabbitMQ**: http://localhost:15672 (guest/guest)
  - Check **Queues** → `activity.queue` should have processed messages

### Check Health
```powershell
.\status.ps1
```

All services should show ✅ Healthy

---

## View Logs

```powershell
# Follow logs for specific service
.\logs.ps1 -Service api-gateway -Follow

# View AI service logs (to see Gemini API calls)
.\logs.ps1 -Service ai-service -Follow
```

---

## Stop Services

```powershell
.\stop.ps1
```

Select `N` to keep data, or `Y` to wipe databases.

---

## Troubleshooting

### Service won't start
```powershell
docker-compose logs -f [service-name]
```

### Port already in use
```powershell
# Find and kill process
netstat -ano | findstr :[port]
taskkill /PID [PID] /F
```

### Keycloak error "Realm not found"
- Double-check realm name is exactly: `fitness-oauth2`
- Restart API Gateway: `docker-compose restart api-gateway`

### AI Service not generating recommendations
- Verify `GEMINI_API_KEY` in `.env` is correct
- Check AI service logs: `.\logs.ps1 -Service ai-service`
- Verify RabbitMQ received message: http://localhost:15672

---

## 🎉 Success!

If you can:
1. ✅ Login to the application
2. ✅ Create an activity
3. ✅ See AI recommendations

**Your containerized microservices are working perfectly!**

---

## Next Steps

- **Production**: Move to Phase 2 (AWS Infrastructure)
- **Development**: Modify code and rebuild specific services
- **Learning**: Explore Eureka dashboard, RabbitMQ queues, and Actuator endpoints

---

Need help? Check:
- **DOCKER_DEPLOYMENT.md** - Detailed deployment guide
- **README.md** - Full documentation
- **CONTAINERIZATION_SUMMARY.md** - What was built
