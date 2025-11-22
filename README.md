# Fitness Tracker - Containerized Deployment

A microservices-based fitness tracking application with AI-powered workout recommendations, fully containerized and ready for cloud deployment.

## 📋 Table of Contents
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Services](#services)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Next Steps: AWS Deployment](#next-steps)

---

## 🏗️ Architecture

```
┌─────────────┐
│   Frontend  │ (React + Nginx)
│  Port 3000  │
└──────┬──────┘
       │
┌──────▼──────────┐
│  API Gateway    │ (Spring Cloud Gateway + OAuth2)
│   Port 8080     │
└────────┬────────┘
         │
    ┌────┴────┬─────────┬─────────┐
    │         │         │         │
┌───▼───┐ ┌──▼──┐  ┌───▼───┐ ┌──▼──┐
│ User  │ │Activ│  │  AI   │ │Eureka│
│Service│ │ity  │  │Service│ │Server│
│ 8081  │ │8082 │  │ 8083  │ │ 8761│
└───┬───┘ └──┬──┘  └───┬───┘ └─────┘
    │        │         │
┌───▼───┐ ┌──▼──────┐ │     ┌──────────┐
│Postgre│ │MongoDB  │ └────►│ RabbitMQ │
│  SQL  │ │Activity │       │   5672   │
│ 5432  │ │ 27017   │       └──────────┘
└───────┘ └─────────┘
          ┌─────────┐
          │MongoDB  │
          │   AI    │
          │ 27018   │
          └─────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine + Docker Compose (Linux)
- 8GB+ RAM available
- Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

### 1️⃣ Setup Environment

```powershell
# Copy environment template
Copy-Item .env.example .env

# Edit .env and add your Gemini API key
notepad .env
```

### 2️⃣ Start All Services

```powershell
# Using the startup script (recommended)
.\start.ps1

# Or manually
docker-compose up --build
```

**⏱️ Startup Time**: 5-10 minutes (first run)

### 3️⃣ Configure Keycloak

**IMPORTANT**: You must configure Keycloak before using the application.

See detailed instructions in [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md#keycloak-configuration-first-time-setup)

**Quick Summary**:
1. Open http://localhost:8181
2. Login: `admin/admin`
3. Create realm: `fitness-oauth2`
4. Create client: `fitness-app` (public, PKCE enabled)
5. Create user: `testuser/password`

### 4️⃣ Access Application

Open http://localhost:3000 and login with your Keycloak user.

---

## 🔧 Services

| Service | Port | Description | Health Check |
|---------|------|-------------|--------------|
| **Frontend** | 3000 | React SPA with Material-UI | http://localhost:3000/health |
| **API Gateway** | 8080 | Routes, auth, CORS | http://localhost:8080/actuator/health |
| **User Service** | 8081 | User management | http://localhost:8081/actuator/health |
| **Activity Service** | 8082 | Activity tracking | http://localhost:8082/actuator/health |
| **AI Service** | 8083 | Gemini AI recommendations | http://localhost:8083/actuator/health |
| **Eureka Server** | 8761 | Service discovery | http://localhost:8761/actuator/health |
| **Config Server** | 8888 | Centralized config | http://localhost:8888/actuator/health |
| **Keycloak** | 8181 | OAuth2/OIDC provider | http://localhost:8181/health/ready |
| **RabbitMQ** | 15672 | Message broker UI | http://localhost:15672 |
| **PostgreSQL** | 5432 | User database | - |
| **MongoDB Activity** | 27017 | Activity database | - |
| **MongoDB AI** | 27018 | Recommendations DB | - |

---

## ⚙️ Configuration

### Environment Variables (.env)

```env
# Required
GEMINI_API_KEY=your_api_key_here

# Optional (defaults provided)
POSTGRES_PASSWORD=database
RABBITMQ_PASSWORD=guest
KEYCLOAK_ADMIN_PASSWORD=admin
```

### Docker Compose Profiles

```powershell
# Start only infrastructure (for local dev)
docker-compose up postgres mongodb-activity mongodb-ai rabbitmq keycloak

# Start specific service
docker-compose up api-gateway
```

---

## 🧪 Testing

### Manual Testing Flow

1. **Open Frontend**: http://localhost:3000
2. **Login**: Click "Log in to Continue" → Keycloak → `testuser/password`
3. **Create Activity**:
   - Type: RUNNING
   - Duration: 30 (minutes)
   - Calories: 300
   - Start Time: Current date/time
4. **Submit**: Activity is saved and sent to RabbitMQ
5. **View Recommendations**: Click activity card → AI recommendations appear

### Check Service Health

```powershell
# Run status check script
.\status.ps1

# Or manually check endpoints
curl http://localhost:8080/actuator/health
```

### View Logs

```powershell
# View logs for specific service
.\logs.ps1 -Service api-gateway -Follow

# View all logs
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100 activity-service
```

### Verify Integrations

**RabbitMQ**: http://localhost:15672 (guest/guest)
- Check queues → `activity.queue` should receive messages

**Eureka Dashboard**: http://localhost:8761
- All services should be registered and UP

---

## 🐛 Troubleshooting

### Services Won't Start

```powershell
# Check Docker is running
docker ps

# View specific service logs
docker-compose logs -f [service-name]

# Restart specific service
docker-compose restart [service-name]
```

### Port Already in Use

```powershell
# Find process using port
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
```

### Database Connection Issues

```powershell
# Restart databases
docker-compose restart postgres mongodb-activity mongodb-ai

# Check database logs
docker-compose logs postgres
```

### Keycloak "Realm Not Found"

- Ensure you created the `fitness-oauth2` realm
- Check API Gateway environment variable points to correct realm
- Verify Keycloak is healthy: http://localhost:8181/health

### Frontend Can't Reach API

- Check CORS settings in API Gateway
- Verify frontend `axios.js` uses correct URL (`http://localhost:8080`)
- Check browser console for CORS errors

### AI Service Not Generating Recommendations

- Verify `GEMINI_API_KEY` is set in `.env`
- Check AI Service logs: `docker-compose logs -f ai-service`
- Verify RabbitMQ connection in logs
- Check RabbitMQ queue has messages: http://localhost:15672

---

## 🛠️ Management Commands

```powershell
# Start services
.\start.ps1

# Stop services
.\stop.ps1

# Check status
.\status.ps1

# View logs
.\logs.ps1 -Service <service-name> [-Follow]

# Rebuild specific service
docker-compose build [service-name]
docker-compose up -d [service-name]

# Clean slate (removes all data)
docker-compose down -v
```

---

## 📊 Monitoring

### Application Metrics
All Spring Boot services expose Actuator endpoints:
- Health: `/actuator/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

### Infrastructure Monitoring
- **RabbitMQ**: http://localhost:15672
- **Eureka Dashboard**: http://localhost:8761
- **Docker Stats**: `docker stats`

---

## 🔐 Security Notes

**For Local Development Only**:
- Default passwords are weak (change for production)
- No TLS/HTTPS configured
- Keycloak uses dev mode
- No rate limiting or DDoS protection

**Production Recommendations**:
- Use secrets management (AWS Secrets Manager, Vault)
- Enable HTTPS with valid certificates
- Implement rate limiting
- Use managed services (RDS, DocumentDB, Amazon MQ)
- Enable audit logging

---

## 📦 Next Steps

### Phase 2: AWS Infrastructure
- ✅ Services containerized
- ⏭️ Create Terraform/CloudFormation for:
  - EKS cluster setup
  - RDS PostgreSQL
  - DocumentDB (MongoDB)
  - ECR repositories
  - VPC and networking

### Phase 3: Kubernetes
- ⏭️ Create K8s manifests (deployments, services, configmaps)
- ⏭️ Setup ingress controller (ALB or NGINX)
- ⏭️ Configure persistent volumes
- ⏭️ Implement auto-scaling

### Phase 4: CI/CD
- ⏭️ Jenkins pipeline for automated builds
- ⏭️ Push images to ECR
- ⏭️ Deploy to EKS with rolling updates
- ⏭️ Implement blue-green deployments

---

## 📚 Documentation

- **[DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md)**: Detailed deployment guide with Keycloak setup
- **[Architecture Diagrams](./docs/)**: System design and data flow
- **[API Documentation](./docs/api/)**: REST API specs (coming soon)

---

## 🤝 Contributing

1. Make code changes in service directory
2. Rebuild service: `docker-compose build [service-name]`
3. Test locally: `docker-compose up [service-name]`
4. Commit changes

---

## 📝 License

[Your License Here]

---

## 🆘 Support

- Check logs: `.\logs.ps1 -Service <name> -Follow`
- View service status: `.\status.ps1`
- Review [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md)
- Check GitHub Issues (if applicable)

---

**Built with**: Spring Boot 3.5, React 18, Docker, Kubernetes, AWS
