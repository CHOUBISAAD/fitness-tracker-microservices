# Fitness Tracker - Cluster Management Guide

## Overview
Your fitness tracker application is deployed on AWS EKS in the `fitness-tracker` namespace.

## Quick Start Scripts

### 🚀 Start the Application
```powershell
.\start-cluster.ps1
```
This will:
1. Start core services (Config Server, Eureka, MongoDB)
2. Wait for them to be ready
3. Start microservices (User, Activity, AI, API Gateway)

### 🛑 Stop the Application
```powershell
.\stop-cluster.ps1
```
This scales all deployments to 0 replicas (saves costs when not in use).

### 📊 Check Status
```powershell
.\check-status.ps1
```
Shows pods, services, and load balancer information.

### 🔄 Restart a Service
```powershell
.\restart-service.ps1 -Service <service-name>
```
Example: `.\restart-service.ps1 -Service ai-service`

Available services:
- config-server
- eureka-server
- user-service
- activity-service
- ai-service
- api-gateway
- mongodb

### 📝 View Logs
```powershell
.\view-logs.ps1 -Service <service-name> [-Lines 100]
```
Example: `.\view-logs.ps1 -Service activity-service -Lines 200`

## Application Architecture

### Services
1. **Config Server** (Port 8888) - Centralized configuration
2. **Eureka Server** (Port 8761) - Service discovery
3. **API Gateway** (Port 8080) - Entry point for all requests
4. **User Service** (Port 8082) - User management
5. **Activity Service** (Port 8083) - Activity tracking
6. **AI Service** (Port 8084) - Gemini AI recommendations
7. **MongoDB** (Port 27017) - Database

### External Services
- **RabbitMQ** (AWS MQ) - Message broker for activity events
- **AWS ECR** - Container registry
- **AWS EKS** - Kubernetes cluster

## API Endpoints

Get the API Gateway URL:
```powershell
kubectl get svc api-gateway -n fitness-tracker
```

### Main Endpoints (via API Gateway)
- `POST /api/users/register` - User registration
- `POST /api/users/login` - User login
- `GET /api/users/{id}` - Get user details
- `GET /api/activities` - List activities
- `POST /api/activities` - Create activity
- `GET /api/recommendations/activity/{activityId}` - Get AI recommendations

## Database Access

### Connect to MongoDB
```powershell
kubectl exec -it mongodb-0 -n fitness-tracker -- mongosh -u mongouser -p mongopass123 --authenticationDatabase admin fitnessdb
```

### View Activities
```powershell
kubectl exec mongodb-0 -n fitness-tracker -- mongosh -u mongouser -p mongopass123 --authenticationDatabase admin fitnessdb --eval "db.activities.find().pretty()"
```

### View Recommendations
```powershell
kubectl exec mongodb-0 -n fitness-tracker -- mongosh -u mongouser -p mongopass123 --authenticationDatabase admin fitnessdb --eval "db.recommendations.find().pretty()"
```

### Delete All Activities
```powershell
kubectl exec mongodb-0 -n fitness-tracker -- mongosh -u mongouser -p mongopass123 --authenticationDatabase admin fitnessdb --eval "db.activities.deleteMany({})"
```

## Troubleshooting

### Check Pod Status
```powershell
kubectl get pods -n fitness-tracker
```

### Check Pod Logs
```powershell
kubectl logs <pod-name> -n fitness-tracker --tail=100
```

### Describe Pod (for debugging)
```powershell
kubectl describe pod <pod-name> -n fitness-tracker
```

### Check Service Endpoints
```powershell
kubectl get endpoints -n fitness-tracker
```

### Restart All Services
```powershell
kubectl rollout restart deployment -n fitness-tracker
```

## Configuration Files

### Kubernetes Deployments
- `k8s/` - All Kubernetes manifests
  - `config-server.yaml`
  - `eureka-server.yaml`
  - `user-service.yaml`
  - `activity-service.yaml`
  - `ai-service.yaml`
  - `api-gateway.yaml`
  - `mongodb.yaml`

### Centralized Configuration
- `config-repo/` - Git repository for Config Server
  - `user-service.yml`
  - `activity-service.yml`
  - `ai-service.yml`
  - `api-gateway.yml`

### Application Code
- `userservice/` - User microservice
- `activityservice/` - Activity microservice
- `aiservice/` - AI recommendation microservice
- `api-gateway/` - API Gateway
- `config-server/` - Config Server
- `eurekaserver/` - Eureka Server

## Important Notes

### Data Persistence
- MongoDB uses a PersistentVolumeClaim (30Gi)
- Data persists even when pods are stopped/restarted
- To delete data, you must manually delete from MongoDB

### Cost Optimization
- Stop the cluster when not in use: `.\stop-cluster.ps1`
- This keeps EKS nodes running but stops all pods
- Data in MongoDB PVC is preserved

### Gemini API Key
- Located in: `k8s/ai-service.yaml`
- Current key: `AIzaSyCN8_RFFhyeZ5ZL-GWmQpO5u52uMYIs3Bs`
- After updating, restart: `.\restart-service.ps1 -Service ai-service`

### RabbitMQ Integration
- Activities trigger AI recommendations automatically
- Connection configured in each service's application.yml
- AWS MQ endpoint: `b-a6ebf0c7-288f-4d2d-b02d-da6f38a3fff9.mq.eu-west-1.on.aws`

## Deployment Workflow

### Update a Service
1. Make code changes
2. Build: `mvn clean package -DskipTests`
3. Build Docker image: `docker build -t 925047941400.dkr.ecr.eu-west-1.amazonaws.com/fitness-tracker-dev-<service>:latest .`
4. Push to ECR: `docker push 925047941400.dkr.ecr.eu-west-1.amazonaws.com/fitness-tracker-dev-<service>:latest`
5. Restart service: `.\restart-service.ps1 -Service <service-name>`

### Update Configuration
1. Edit file in `config-repo/`
2. Commit and push to GitHub
3. Restart Config Server: `.\restart-service.ps1 -Service config-server`
4. Restart affected services

## Monitoring

### Check All Pods Health
```powershell
kubectl get pods -n fitness-tracker -w
```

### Check Service Discovery (Eureka)
Forward port and access in browser:
```powershell
kubectl port-forward svc/eureka-server 8761:8761 -n fitness-tracker
```
Open: http://localhost:8761

### Check RabbitMQ
Access AWS Console > Amazon MQ > Your Broker

## Backup & Recovery

### Backup MongoDB
```powershell
kubectl exec mongodb-0 -n fitness-tracker -- mongodump --uri="mongodb://mongouser:mongopass123@localhost:27017/fitnessdb?authSource=admin" --out=/tmp/backup
kubectl cp fitness-tracker/mongodb-0:/tmp/backup ./mongodb-backup
```

### Restore MongoDB
```powershell
kubectl cp ./mongodb-backup fitness-tracker/mongodb-0:/tmp/backup
kubectl exec mongodb-0 -n fitness-tracker -- mongorestore --uri="mongodb://mongouser:mongopass123@localhost:27017/fitnessdb?authSource=admin" /tmp/backup/fitnessdb
```

## Support

For issues or questions:
1. Check logs: `.\view-logs.ps1 -Service <service-name>`
2. Check pod status: `kubectl get pods -n fitness-tracker`
3. Describe problematic pod: `kubectl describe pod <pod-name> -n fitness-tracker`
4. Check service endpoints: `kubectl get endpoints -n fitness-tracker`
