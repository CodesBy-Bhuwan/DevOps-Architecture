# MERN Deployment

# Abstract
- **Code**  -> Packaged into Images via Dockerfile.
- **Images**    -> Run as Containers on a custom Network.
- **Nginx** -> sits at the front door (Port 80), dynamically routing traffic  to the appropriate containers.
- **Data**  ->is seeded into the database via mongoimport.

## 1. Create Dockerfiles:
**Backend**
```bash
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

**Frontend**
```bash
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173
# The --host 0.0.0.0 is REQUIRED so Nginx can reach it inside the Docker network
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

If possible for nginx, database as well if not we can use official images

hub.docker/mongo && hub.dokcer/nginx

## 2. Create Docker Network
```bash
docker network create wand
```

## 3. Build the Images
```bash
For backend
docker build -t backend:v1 backend/.

For frontend
docker build -t frontend:v1 frontend/.
```

## 4. Run the images
```bash
docker run -d --name mongodb --network wand -p 27017:27017 mongo:latest

docker run -d --name backend --network wand -p 5000:5000 
  -e PORT=5000 \
  -e MONGODB_URI=mongodb://mongodb:27017/wanderlust \
  -e CORS_ORIGIN=http:/192.168.56.10 \
  backend:v1

docker run -d --name frontend --network wand -p 5173:5173 \
  -e VITE_API_PATH=http://192.168.56.10 \
  frontend:v1
```

## 5. Seed the database with mongoimport

If you have a JSON file of data to feed into MongoDB, you can use mongoimport. You copy the file into the running Mongo container, then execute the import command.
```bash
# 1. Copy the file from your host to the container
docker cp ./backend/data/sample-post.json mongodb:/sample-post.json

# 2. Run mongoimport inside the container
docker exec mongodb mongoimport --db wanderlust --collection posts --file /sample-post.json --jsonArray
```

## 6. Setup nginx for Dynamic Deployment
Instead of hardcoding ports in the browser, Nginx will intercept traffic on port 80 and route it dynamically to the frontend or backend.

```nano nginx.conf```

```bash
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    log_format proxy_log '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        'upstream: $upstream_addr';

    access_log /var/log/nginx/access.log proxy_log;
    error_log  /var/log/nginx/error.log warn;

    client_max_body_size 50M;

    upstream frontend_upstream {
        server frontend:5173;
    }

    upstream backend_upstream {
        server backend:5000;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://frontend_upstream;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /api/ {
            proxy_pass http://backend_upstream;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

**nginx**
```bash
docker run -d --name nginx-proxy --network wand -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/nginx-logs:/var/log/nginx \
  nginx:latest
```

## 7: Verify Connectivity (Checking the Links)
Now we verify that every container can talk to the next one in the chain.

1. Check Nginx -> Frontend & Backend:
Open your browser and go to http://192.168.56.10. You should see the frontend. Check the logs:

```bash
docker exec nginx-proxy tail -f /var/log/nginx/access.log
```
You should see requests going to frontend:5173 and backend:5000.

2. Check Backend -> Database:
Let's ask the backend to query the database directly:

```bash
docker exec nginx-proxy curl -s http://backend:5000/api/posts
```

If it returns JSON data, the backend successfully connected to MongoDB!

3. Check Nginx -> Backend (Direct test):

```bash
docker exec nginx-proxy curl -I http://backend:5000
```

This returns HTTP 200, proving Nginx can reach the backend.

