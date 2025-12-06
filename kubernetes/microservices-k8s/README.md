# Microservices on Kubernetes

Modern microservices architecture with API Gateway, multiple services, and data layer.

## Architecture

API Gateway → [User Service, Product Service, Order Service] → [MongoDB, Redis, RabbitMQ]

## Components

- API Gateway (nginx)
- 3 Microservices (User, Product, Order)
- MongoDB (StatefulSet)
- Redis (Deployment)
- RabbitMQ (StatefulSet)

## Deploy

```bash
kubectl apply -f all-in-one.yaml
```
