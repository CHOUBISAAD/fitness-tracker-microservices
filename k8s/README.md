# Kubernetes Deployment Guide

## Prerequisites
- EKS cluster configured with kubectl
- Docker images pushed to ECR
- Database credentials from Terraform outputs

## Deployment Order

Deploy in this order to ensure dependencies are met:

```powershell
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Create secrets and config
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml

# 3. Deploy databases (wait for MongoDB to be ready)
kubectl apply -f mongodb-statefulset.yaml
kubectl apply -f keycloak-statefulset.yaml

# Wait for MongoDB and Keycloak to be ready
kubectl wait --for=condition=ready pod -l app=mongodb -n fitness-tracker --timeout=300s
kubectl wait --for=condition=ready pod -l app=keycloak -n fitness-tracker --timeout=300s

# 4. Deploy service discovery (Eureka first)
kubectl apply -f eureka-server.yaml

# Wait for Eureka to be ready
kubectl wait --for=condition=ready pod -l app=eureka-server -n fitness-tracker --timeout=180s

# 5. Deploy config server
kubectl apply -f config-server.yaml

# Wait for Config Server to be ready
kubectl wait --for=condition=ready pod -l app=config-server -n fitness-tracker --timeout=180s

# 6. Deploy microservices
kubectl apply -f user-service.yaml
kubectl apply -f activity-service.yaml
kubectl apply -f ai-service.yaml

# 7. Deploy gateway and frontend
kubectl apply -f api-gateway.yaml
kubectl apply -f frontend.yaml
```

## Quick Deploy All (Alternative)
```powershell
cd c:\microApp\k8s
kubectl apply -f .
```

## Verify Deployment
```powershell
# Check all pods
kubectl get pods -n fitness-tracker

# Check services and external IPs
kubectl get services -n fitness-tracker

# Check persistent volumes
kubectl get pvc -n fitness-tracker

# Watch pod status
kubectl get pods -n fitness-tracker -w

# Check logs of a specific pod
kubectl logs -f <pod-name> -n fitness-tracker
```

## Get LoadBalancer URLs
```powershell
# API Gateway URL
kubectl get service api-gateway-service -n fitness-tracker -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Frontend URL
kubectl get service frontend-service -n fitness-tracker -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Keycloak URL
kubectl get service keycloak-service -n fitness-tracker -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Access Applications
After deployment (LoadBalancer provisioning takes 2-3 minutes):
- **Frontend**: http://<frontend-lb-url>
- **API Gateway**: http://<gateway-lb-url>:8080
- **Keycloak Admin**: http://<keycloak-lb-url>:8080 (admin/admin123)
- **Eureka Dashboard**: Port-forward to access: `kubectl port-forward svc/eureka-service 8761:8761 -n fitness-tracker`

## Troubleshooting
```powershell
# Describe a pod
kubectl describe pod <pod-name> -n fitness-tracker

# Check events
kubectl get events -n fitness-tracker --sort-by='.lastTimestamp'

# Check pod logs
kubectl logs <pod-name> -n fitness-tracker --previous

# Shell into a pod
kubectl exec -it <pod-name> -n fitness-tracker -- /bin/sh
```

## Scaling
```powershell
# Scale a deployment
kubectl scale deployment user-service --replicas=3 -n fitness-tracker

# Auto-scaling (optional)
kubectl autoscale deployment user-service --min=2 --max=5 --cpu-percent=80 -n fitness-tracker
```

## Update Images
```powershell
# After pushing new image to ECR
kubectl rollout restart deployment/<deployment-name> -n fitness-tracker

# Check rollout status
kubectl rollout status deployment/<deployment-name> -n fitness-tracker
```

## Cleanup
```powershell
# Delete all resources in namespace
kubectl delete namespace fitness-tracker

# Or delete individual resources
kubectl delete -f .
```

## Notes
- MongoDB uses persistent storage (5GB volume)
- Keycloak uses RDS PostgreSQL (shared with user-service)
- RabbitMQ uses managed Amazon MQ (not deployed in cluster)
- LoadBalancer services will provision AWS ELBs (additional cost)
- Initial startup may take 5-10 minutes for all services to be ready
