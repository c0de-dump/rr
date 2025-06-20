# Docker Compose Setup for Rails Job Processing

This setup provides a complete Rails application with separate web server and worker services for background job processing.

## Architecture

- **Web Server**: Handles HTTP requests and creates jobs
- **Worker Service**: Processes background jobs from the queue
- **Database**: PostgreSQL for data persistence
- **Zipkin**: For distributed tracing

## Services

### Web Server (`web`)
- Runs the Rails web application
- Handles HTTP requests
- Creates and enqueues background jobs
- Exposes port 3000
- Has job processing disabled (`JOB_CONCURRENCY=0`)

### Worker Service (`worker`)
- Processes background jobs using SolidQueue
- Runs multiple worker processes
- Scales independently from web server
- Can be replicated for high availability

### Supporting Services
- **PostgreSQL**: Primary database with separate databases for cache, queue, and cable
- **Zipkin**: Distributed tracing for monitoring

## Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Update .env file** with your `RAILS_MASTER_KEY`:
   ```bash
   # Get your master key
   cat config/master.key
   
   # Update .env file
   vim .env  # Set RAILS_MASTER_KEY=your_key_here
   ```

3. **Deploy using the script:**
   ```bash
   ./scripts/deploy.sh
   ```

   Or manually:
   ```bash
   docker-compose build
   docker-compose up -d db zipkin
   docker-compose run --rm web bin/rails db:create db:migrate
   docker-compose up -d
   ```

## Usage

### Creating Jobs via API

```bash
# Create a simple job
curl -X POST http://localhost:3000/jobs \
  -H 'Content-Type: application/json' \
  -d '{"message":"Hello World!", "delay":0}'

# Create a delayed job
curl -X POST http://localhost:3000/jobs \
  -H 'Content-Type: application/json' \
  -d '{"message":"Delayed job", "delay":10}'
```

### Monitoring

```bash
# Check application health
curl http://localhost:3000/health

# List recent jobs
curl http://localhost:3000/jobs

# Check job status
curl http://localhost:3000/jobs/JOB_ID/status

# View logs
docker-compose logs -f web     # Web server logs
docker-compose logs -f worker  # Worker logs
docker-compose logs -f         # All services
```

### Scaling Workers

```bash
# Scale to 3 worker instances
docker-compose up -d --scale worker=3

# Check worker status
docker-compose ps worker
```

## Endpoints

- **GET /health** - Health check endpoint
- **POST /jobs** - Create a new background job
- **GET /jobs** - List recent jobs
- **GET /jobs/:id/status** - Check job status

## Development

For development, you can still use the local Rails server:

```bash
# Start only supporting services
docker-compose up -d db zipkin

# Run Rails locally
bin/rails server

# Run worker locally
bin/rails solid_queue:start
```

## Environment Variables

Key environment variables (see `.env.example`):

- `RAILS_MASTER_KEY`: Rails master key for credentials
- `DATABASE_URL`: PostgreSQL connection string
- `JOB_CONCURRENCY`: Number of worker processes

## Troubleshooting

### Database Connection Issues
```bash
# Check database status
docker-compose logs db

# Reset database
docker-compose down -v
docker-compose up -d db
docker-compose run --rm web bin/rails db:create db:migrate
```

### Worker Not Processing Jobs
```bash
# Check worker logs
docker-compose logs worker

# Restart workers
docker-compose restart worker

# Check job queue
docker-compose exec web bin/rails runner "puts SolidQueue::Job.count"
```

### View Distributed Traces
Visit http://localhost:9411 to view Zipkin traces showing job processing across services.
