# Starting Fitness Tracker with Existing Keycloak & RabbitMQ

## Prerequisites - Start Your Existing Containers

Before running docker-compose, start your existing containers:

```powershell
# Start RabbitMQ
docker start rabbitmq

# Start Keycloak
docker start infallible_heisenberg

# Verify they're running
docker ps --filter "name=rabbitmq" --filter "name=infallible_heisenberg"
```

**Expected Output:**
- `rabbitmq` - Status: Up, Ports: 5672, 15672
- `infallible_heisenberg` - Status: Up, Ports: 8080 (mapped to host 8181)

---

## Step 1: Configure Environment

```powershell
# Edit .env file and add your Gemini API key
notepad .env
```

---

## Step 2: Start Microservices

```powershell
.\start.ps1
```

The script will start:
- ✅ PostgreSQL (new container)
- ✅ 2x MongoDB (new containers)
- ✅ Eureka, Config Server, Gateway, User/Activity/AI Services
- ✅ Frontend

**Note:** RabbitMQ and Keycloak will be used from your existing containers.

---

## Step 3: Verify Connections

### Check RabbitMQ Connection
```powershell
# View Activity Service logs (should connect to localhost:5672)
.\logs.ps1 -Service activity-service -Follow

# Check AI Service logs  
.\logs.ps1 -Service ai-service -Follow
```

Look for: `✅ Connected to RabbitMQ at host.docker.internal:5672`

### Check Keycloak Connection
```powershell
# View API Gateway logs
.\logs.ps1 -Service api-gateway -Follow
```

Look for: `✅ JWK Set URI loaded from host.docker.internal:8181`

---

## Step 4: Test Application

1. **Open Frontend**: http://localhost:3000
2. **Login with existing Keycloak user** (your realm should already be configured)
3. **Create Activity** and verify it works

---

## Troubleshooting

### Services can't connect to RabbitMQ
```powershell
# Verify RabbitMQ is accessible from host
Test-NetConnection -ComputerName localhost -Port 5672
Test-NetConnection -ComputerName localhost -Port 15672

# Check RabbitMQ is running
docker ps --filter "name=rabbitmq"
```

### Services can't connect to Keycloak
```powershell
# Verify Keycloak is accessible
curl http://localhost:8181/health

# Check Keycloak container
docker ps --filter "name=infallible_heisenberg"
```

### "host.docker.internal" not resolving
- On Windows/Mac: Should work automatically
- On Linux: Add to each service in docker-compose:
  ```yaml
  extra_hosts:
    - "host.docker.internal:172.17.0.1"
  ```

---

## What Changed?

**Removed from docker-compose:**
- ❌ RabbitMQ container definition
- ❌ Keycloak container definition
- ❌ Keycloak PostgreSQL database

**Updated Services:**
- ✅ Activity Service → connects to RabbitMQ via `host.docker.internal:5672`
- ✅ AI Service → connects to RabbitMQ via `host.docker.internal:5672`
- ✅ API Gateway → connects to Keycloak via `host.docker.internal:8181`

**Why `host.docker.internal`?**
- Allows Docker containers to access services running on the host machine
- Automatically resolves to the host's IP address

---

## Stop Services

```powershell
# Stop docker-compose services
.\stop.ps1

# Optionally stop your external containers
docker stop rabbitmq infallible_heisenberg
```

---

## Benefits of This Setup

✅ **Keep your existing Keycloak configuration** (realm, clients, users)  
✅ **Keep your existing RabbitMQ setup** (exchanges, queues, data)  
✅ **No need to reconfigure** authentication or message broker  
✅ **Microservices still containerized** for cloud deployment readiness  

---

## Next Steps

Once tested locally with external containers, for AWS deployment we'll:
1. Use **Amazon MQ** (managed RabbitMQ)
2. Deploy Keycloak to EKS or use **Amazon Cognito**
3. All microservices will connect via internal K8s service names
