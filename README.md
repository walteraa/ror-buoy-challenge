# README

**Required Ruby version: 3.2.2**

A simple Rails API for accommodations and bookings.

## Challenge context

This repository contains a partially implemented accommodations booking REST API, designed as a work-in-progress prototype for a real-world application.

### Submission and workflow
- Host your solution in a cloud git repository of your choice.
- The first commit must:
  - Have the message "First commit"
  - Contain the exact code sample as it was provided, with no changes
- From this point on, work on the problems below as you prefer.
- If you create a private repository, grant `matthew@buoydevelopment.com` full access and make that clear in your response.

### Problems

Note: Treat each exercise as production-ready work. Solutions should be suitable to ship: designed for stability under realistic usage, correct when multiple clients act at the same time, mindful of scale, and operationally sound (documentation, tests, migration strategy, and maintainability). Avoid toy or purely illustrative implementations.

- **Problem #1 — Entities**
  - There's an `Accommodation` base concept, but the business domain only includes `Hotel` and `Apartment`.
  - Expected: Add these 2 entities and provide endpoints for their management.
  - Production expectation: Deliver an API and data model appropriate for a real system, with attention to interface design, correctness, and long-term maintainability.

- **Problem #2 — Overlapping bookings**
  - Currently, every accommodation can contain several overlapping bookings for the same `start_date` and `end_date`.
  - Expected: Apartments must not allow overlapping bookings during the same period. Hotels should allow overlapping bookings for the same period (different rooms booked simultaneously).
  - Production expectation: Ensure the approach remains correct under concurrent access and when requests may be retried. Favor solutions that provide clear guarantees and are observable in operation.

- **Problem #3 — Next available date**
  - Given an accommodation `id` and a `date`, retrieve the next available date for that accommodation.
  - Questions to address:
    - Explain the client-facing contract you would establish with the frontend team to consume this capability.
    - Explain the algorithm you would use to solve this problem.

## Tech context

- **Stack**: Ruby on Rails (API), Active Record (PostgreSQL), Rswag for Swagger docs.
- **Docs**: Interactive API docs served at `/api-docs` when the server is running.

## What we assess
- Architecture and data modeling suitable for long-term evolution
- Correctness when multiple clients act concurrently and safe handling of request retries
- Performance characteristics and sensible use of database capabilities
- API design quality, documentation, and versioning discipline
- Testing depth that exercises critical behaviors and edge cases
- Operational readiness: migrations, observability, error handling, and maintainability

## API overview

- Explore and try the endpoints in Swagger: `http://localhost:3000/api-docs/index.html`.

### Prerequisites
- Ruby 3.2.2 and Bundler
- Docker and Docker Compose

No local PostgreSQL installation is required; the database runs in Docker.

### Run modes

#### Mode A: Local Rails + Dockerized Postgres
Use Docker only for the database; run Rails on your host.

1. Start the database:
   ```sh
   docker compose up -d db
   ```
2. Install gems (host):
   ```sh
   bundle install
   ```
3. Prepare the database (create + migrate):
   ```sh
   bundle exec rails db:prepare
   # optional sample data
   bundle exec rails db:seed
   ```
4. Start Rails (host):
   ```sh
   bundle exec rails s
   ```
5. Open API docs: `http://localhost:3000/api-docs/index.html`

Notes:
- `config/database.yml` is set to connect to `localhost:5432` with `postgres/postgres` for development/test.
- If you previously exported `DATABASE_URL` in your shell, unset it to avoid overrides: `unset DATABASE_URL`.

#### Mode B: Full Docker (web + db)
Run both the app and database in containers.

1. Build images:
   ```sh
   docker compose build
   ```
2. Start services:
   ```sh
   docker compose up
   ```
   The entrypoint automatically runs `rails db:prepare` on startup.
3. (Optional) Seed sample data:
   ```sh
   docker compose run --rm web bundle exec rails db:seed
   ```
4. App URL: `http://localhost:3000`
5. API docs: `http://localhost:3000/api-docs/index.html`

### Running tests
- Host (Mode A):
  ```sh
  bundle exec rspec
  ```
- Docker (Mode B):
  ```sh
  docker compose run --rm web bundle exec rspec
  ```

### Helpful commands
- Reset DB (drop, create, migrate, seed) on host:
  ```sh
  bundle exec rails db:reset && bundle exec rails db:seed
  ```
- Verify DB readiness (Docker DB):
  ```sh
  docker compose exec db pg_isready -U postgres -h localhost -p 5432
  ```

---
If something doesn’t work, confirm your Ruby version matches `.ruby-version`, Docker is running, and that the DB container is up (`docker compose ps`).


## Solution

To solve this challenge, I was inspired in the approach the top-tier booking products(airbnb, booking.com, etc) use: an async booking system. But in that case a simpler and rails-like way.
For this, I decided to add an action to create the BookingRequest and then, we have a Sidekiq worker being trigger as a queue, considering the accommodation_id as the unique key.

If everything went fine(e.g.: checks for overlap), we create the actual Booking and change the BookingRequest.status to sucess, otherwise we change the BookingRequest.status to failed.

![System architecture](docs/macro_diagram.png)


To reach this, I followed the model architecture below



![Model architecture](docs/model_diagram.png)
