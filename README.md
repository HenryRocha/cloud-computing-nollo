# Cloud Computing - Nollo

Final project for Insper's 2020.2 Cloud Computing class. Create an application that uses AWS and resides on multiple regions.

Roadmap:
- Infrastructure
    - [X] Database instance
    - [X] Database instance on private subnet
    - [X] Backend instace with Load Balancer
    - [X] Backend instace with Auto Scaling
    - [X] Custom VPC and subnets for backend
    - [X] Frontend instace with Load Balancer
    - [X] Frontend instace with Auto Scaling
    - [X] Custom VPC and subnets for frontend
    - [X] VPN connection between VPCs
- Backend
    - [x] REST API (Go Fiber)
    - [x] ORM (GORM) 
- Frontend:
    - [X] Client (Svelte App)

![Complete Infrastructure Diagram][1]
![Backend Infrastructure Diagram][2]
![Frontend Infrastructure Diagram][3]

[1]: ./infrastructure/diagram-complete.drawio.svg
[2]: ./infrastructure/diagram-backend.drawio.svg
[3]: ./infrastructure/diagram-frontend.drawio.svg
