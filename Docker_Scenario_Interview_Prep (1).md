# Docker — Scenario-Based Interview Prep
## Basic to Advanced | VERDICT-7 Framework | Ajith Kumar

---

# THE FRAMEWORK — APPLY TO EVERY DOCKER SCENARIO

```
V — Version      → Which Docker version? Which image tag? What changed recently?
E — Environment  → Dev/staging/prod? All containers or specific one?
R — Resources    → CPU, memory, disk — is the container hitting limits?
D — Dependencies → Base image, linked containers, external services broken?
I — Infra health → Docker daemon healthy? Host OS under stress?
C — Connectivity → Container networking, port bindings, DNS resolution inside container?
T — Telemetry    → docker logs, docker inspect, docker stats — what do they say?
```

**The 5-second opener for every Docker question:**
> "Let me think through which layer this is — image build, container runtime,
> networking, or storage. My first check would be..."

---

# THE DOCKER MENTAL MODEL

```
Image Layer      → Dockerfile → docker build → image in registry
                        ↓
Runtime Layer    → docker run → container (running instance of image)
                        ↓
Network Layer    → bridge/host/overlay → container-to-container communication
                        ↓
Storage Layer    → volumes/bind mounts → persistent data outside container
```

**When any Docker problem hits — ask:**
1. Is it a BUILD problem? → Check Dockerfile, layers, cache
2. Is it a RUNTIME problem? → Check resource limits, env vars, startup command
3. Is it a NETWORK problem? → Check port bindings, container DNS, bridge networks
4. Is it a STORAGE problem? → Check volume mounts, permissions, disk space

---

---

# SECTION 1 — IMAGE & BUILD SCENARIOS

---

## SCENARIO 1 — Basic
### "Your Docker build is failing. How do you debug it?"

**VERDICT-7 scan:**
```
V → What changed in the Dockerfile or build context?
E → Failing in CI pipeline or locally?
R → Is the build machine out of disk space?
D → Is the base image available? Did registry go down?
I → Is Docker daemon running?
C → Can the build machine reach the internet for package downloads?
T → docker build output — read the exact error line ← answers 90% of cases
```

**The answer:**

"The build output tells you exactly which step failed and why.
Read it carefully — most developers scroll past the actual error.

**Step 1 — Read the failing step:**
```
Step 7/12 : RUN pip install -r requirements.txt
 ---> Running in a3f2b1c4d5e6
ERROR: Could not find a version that satisfies the requirement flask==99.0
```
The step number, the command, and the error are all there.

**Common failures and fixes:**

**Package not found:**
- Wrong version in requirements.txt or package.json
- Fix: correct the version or use a flexible version like `flask>=2.0`

**Base image not found:**
- `FROM python:3.11-nonexistent` — wrong tag
- Check Docker Hub for correct tag names
- Fix: `FROM python:3.11-slim` — verify tag exists

**Network failure during build:**
- pip install or apt-get can't reach the internet
- Fix: check proxy settings, use `--network host` flag if needed
- In CI: check if runner has internet access

**COPY file not found:**
- `COPY app.py .` but app.py doesn't exist in build context
- Check .dockerignore — you might be ignoring the file you need
- Fix: verify file path relative to Dockerfile location

**Permission denied:**
- Build step tries to write to a read-only location
- Fix: create the directory first, set correct ownership

**Step 2 — Use --no-cache to rule out cache issues:**
```bash
docker build --no-cache -t myapp .
```
If it works without cache — your cache is stale. Clear it.

**To prevent:** Add docker build to CI pipeline early. Catch build failures before they reach staging."

---

## SCENARIO 2 — Basic
### "Your Docker image is 2GB. How do you reduce it?"

**VERDICT-7 scan:**
```
V → What base image are you using?
E → (not environment-specific)
R → 2GB = wasted disk, slow pushes, slow pulls, larger attack surface
D → Are you including dev dependencies in prod image?
I → (not infra)
C → Large images = slow container startup = slow pod scheduling in K8s
T → docker history <image> ← shows layer sizes, which layer is biggest
```

**The answer:**

"Large images slow everything — builds, pushes, pulls, and pod startup in Kubernetes. Every MB matters in production.

**Step 1 — Find the fat layer:**
```bash
docker history myapp:latest
```
Shows each layer and its size. The big one is your target.

**Fix 1 — Use a slim or alpine base image:**
```dockerfile
# Before — full image
FROM python:3.11           # 1.1GB

# After — slim
FROM python:3.11-slim      # 125MB

# After — alpine (smallest)
FROM python:3.11-alpine    # 50MB
```
This one change often cuts image size by 60-70%.

**Fix 2 — Multi-stage builds (most powerful):**
```dockerfile
# Stage 1 — builder (has compilers, dev tools)
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2 — final (only runtime, no build tools)
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app.py .
CMD ["python", "app.py"]
```
Build tools stay in stage 1. Only the compiled output moves to stage 2.
Final image has no compiler, no pip cache, no dev tools.

**Fix 3 — Clean up in the same RUN layer:**
```dockerfile
# WRONG — cleanup creates a new layer, original layer still stored
RUN apt-get install -y curl
RUN apt-get clean

# RIGHT — same RUN = one layer, cleanup included
RUN apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*
```

**Fix 4 — Use .dockerignore:**
```
node_modules/
.git/
*.log
tests/
docs/
```
Keeps build context small — speeds up build and avoids copying junk.

**Fix 5 — Don't install dev dependencies:**
```dockerfile
RUN pip install --no-dev -r requirements.txt
# or
RUN npm install --production
```

**To say:**
'My first step is always docker history to find the fat layer. Then I switch to a slim base image and add multi-stage builds if there are compilation steps. These two changes alone usually get a 2GB image down to under 200MB.'"

---

## SCENARIO 3 — Intermediate
### "Docker build works locally but fails in CI pipeline. Same code. What's different?"

**VERDICT-7 scan:**
```
V → Did something change in CI runner environment?
E → Local vs CI = different environments ← this IS the issue
R → CI runner might have less memory/disk than local machine
D → Are dependencies available from CI network? Proxy? Private registry?
I → Is Docker version different between local and CI?
C → CI runner might be behind a proxy or firewall blocking package downloads
T → Compare local build log vs CI build log line by line ← find where it diverges
```

**The answer:**

"'Works locally but fails in CI' is one of the most common Docker problems. The build environment is different even though the code is the same.

**The environment differences to check:**

**Docker version mismatch:**
```bash
# check locally
docker --version

# check in CI (add this step)
- run: docker --version
```
Some Dockerfile features aren't available in older Docker versions.
Fix: Pin Docker version in CI to match local.

**Architecture mismatch:**
Your Mac runs ARM64 (Apple Silicon). CI runner runs AMD64.
```bash
# build for specific platform
docker buildx build --platform linux/amd64 -t myapp .
```

**Private registry access:**
CI runner can't pull the base image from a private registry.
Fix: Add registry login step in CI pipeline before docker build.

**Proxy/firewall blocking packages:**
pip install or npm install can't reach the internet from CI.
Fix: Configure proxy in Dockerfile or use a private package mirror.

**Build context too large:**
Locally you have .dockerignore. CI might not — entire node_modules copied.
Fix: Ensure .dockerignore is committed to the repo.

**Environment variables missing:**
Build args required but not set in CI.
```dockerfile
ARG APP_VERSION
RUN echo $APP_VERSION > version.txt
```
Fix: Add `--build-arg APP_VERSION=1.0` in CI pipeline.

**The debug approach:**
Add `docker info` and `docker version` as first steps in CI.
Compare the output with your local environment.
The difference is your answer.

**To say:**
'I'd compare the CI build log with my local build log step by step and find where they diverge. Then I check the environment differences — Docker version, architecture, network access, and registry credentials. CI failures that work locally are almost always an environment configuration issue.'"

---

## SCENARIO 4 — Advanced
### "Your Docker image builds successfully but the container exits immediately when run. How do you debug?"

**VERDICT-7 scan:**
```
V → Did CMD or ENTRYPOINT change recently?
E → All environments or specific?
R → Exit code? 0 = command completed. 1 = error. 137 = OOM.
D → Does the app need env vars or config files that aren't present?
I → (less likely)
C → Does app try to bind a port that's already in use?
T → docker logs <container> ← the app's output before it died is here
```

**The answer:**

"Container exits immediately = the main process inside the container stopped.
Docker runs containers as long as the main process lives. Process dies = container dies.

**Step 1 — Check exit code:**
```bash
docker run myapp
docker ps -a   # shows exited containers
docker inspect <container_id> | grep ExitCode
```
- ExitCode 0 = process completed successfully — wrong for a server app
- ExitCode 1 = application error
- ExitCode 137 = killed by OOM killer (memory limit)
- ExitCode 139 = segmentation fault

**Step 2 — Read the logs:**
```bash
docker logs <container_id>
```
The app's last output before dying is here. Almost always tells you the root cause.

**ExitCode 0 — process finished:**
You're running a one-shot command as a server.
```dockerfile
# WRONG — echo runs and exits
CMD ["echo", "hello"]

# WRONG — python script finishes immediately
CMD ["python", "run_once.py"]

# RIGHT — long-running server process
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
```

**ExitCode 1 — application crash:**
Missing environment variable:
```
KeyError: 'DATABASE_URL'
```
Fix: Pass required env vars: `docker run -e DATABASE_URL=... myapp`

Can't connect to dependency:
```
Connection refused: localhost:5432
```
Fix: Database isn't running or isn't linked. Use docker-compose.

**ExitCode 137 — OOM:**
Container hit memory limit and was killed.
Fix: `docker run --memory=512m myapp` — increase limit or fix memory leak.

**Debug trick — override CMD to keep container alive:**
```bash
docker run -it --entrypoint sh myapp
```
Drops you into a shell inside the container. Manually run your app command. See the exact error.

**To say:**
'First I check the exit code — it tells me the category of failure. Then docker logs gives me the actual error message. If I need to dig deeper, I override the entrypoint with sh and run the application manually inside the container to see the exact error in real time.'"

---

---

# SECTION 2 — CONTAINER RUNTIME SCENARIOS

---

## SCENARIO 5 — Intermediate
### "A container is consuming 100% CPU and slowing down the host. What do you do?"

**VERDICT-7 scan:**
```
V → Did a new version of the app deploy recently?
E → One container or multiple?
R → CPU = 100% ← this IS the resource problem
D → Is the app stuck in an infinite loop? Waiting for a dependency that never responds?
I → Is the host itself OK? Or is this container starving other containers?
C → Is the app stuck retrying a failed network connection in a tight loop?
T → docker stats ← real-time CPU/memory per container. docker top ← processes inside container
```

**The answer:**

"100% CPU from one container threatens the host — it can starve other containers and destabilize the entire system.

**Immediate action — limit the container:**
```bash
# Update running container CPU limit without restart
docker update --cpus="0.5" <container_id>
```
This caps the container at 50% of one CPU core. Immediate relief.

**Identify the cause:**

**See what's running inside:**
```bash
docker top <container_id>
```
Shows processes and their CPU usage inside the container.

**Check application logs:**
```bash
docker logs --tail 100 <container_id>
```
Is it stuck in a retry loop? Thrashing on an error?

**Common causes:**

**Infinite retry loop:**
App can't reach database. Retries immediately with no backoff.
Each retry uses CPU. 1000 retries/second = 100% CPU.
Fix: Add exponential backoff to retry logic.

**Runaway process:**
A background job went infinite.
Fix: Kill the process inside container, fix the code.

**CPU-intensive operation that shouldn't run continuously:**
Log rotation, compression, or report generation triggered continuously.
Fix: Add proper scheduling, not continuous loop.

**Memory pressure causing GC thrashing:**
App is near memory limit. Garbage collector runs constantly trying to free memory.
Looks like CPU problem but is actually memory problem.
Fix: Increase memory limit first.

**Proper fix — set CPU limits in production:**
```bash
docker run --cpus="1.0" --memory="512m" myapp
```
In Kubernetes: always set resource requests and limits.
A container without limits can consume everything.

**To say:**
'Immediate action is docker update to cap the CPU — protect the host first. Then docker top to see which process is spinning. Almost always it's a retry loop or missing backoff on a failed dependency. The permanent fix is both the code fix AND setting CPU limits so one container can never consume the entire host.'"

---

## SCENARIO 6 — Intermediate
### "Container was working fine but suddenly can't connect to the database. Nothing changed."

**VERDICT-7 scan:**
```
V → Really nothing changed? Check: DB restart? Network change? IP change?
E → This container only or all containers trying to reach DB?
R → (not resource)
D → Database IS the dependency ← focus here
I → Did the DB container restart and get a new IP?
C → Container DNS, network bridge, firewall ← most likely
T → docker exec ping, curl, nslookup inside container ← isolate exactly where it breaks
```

**The answer:**

"'Nothing changed' is almost never true. Something changed — either the container, the network, or the database.

**Step 1 — Test connectivity from inside the container:**
```bash
docker exec -it <container> sh
ping db-container-name    # can it reach by name?
curl http://db:5432       # can it reach by port?
nslookup db               # does DNS resolve?
```
This isolates whether it's DNS, network, or the DB itself.

**Step 2 — Check if DB container restarted:**
```bash
docker inspect <db_container> | grep IPAddress
```
If DB container restarted, it got a new IP address.
Your app has the old IP hardcoded — won't work.

**Why this happens:**
Docker assigns IPs dynamically. If you connect by IP instead of container name — any restart breaks it.
Fix: Always connect by container name or service name, never by IP.
```
# WRONG
DATABASE_URL=postgres://172.17.0.3:5432/mydb

# RIGHT
DATABASE_URL=postgres://db:5432/mydb
```

**Step 3 — Check if they're on the same network:**
```bash
docker network inspect bridge
```
Containers on different networks can't talk to each other.
Fix: Put both containers on the same custom network:
```bash
docker network create myapp-network
docker run --network myapp-network --name db postgres
docker run --network myapp-network --name app myapp
```

**Step 4 — Check DB logs:**
```bash
docker logs db-container
```
Maybe the DB is running but rejected the connection — wrong password, max connections reached.

**To prevent:**
Use docker-compose — it handles networking automatically.
Services defined in the same compose file can reach each other by service name.
Networks are created and managed automatically."

---

## SCENARIO 7 — Advanced
### "You need to run a container in production but the app writes sensitive data to logs. How do you handle it?"

**The answer:**

"Sensitive data in logs is a security and compliance issue — especially for banking applications.

**The problem:**
Logs are often shipped to centralized logging (Splunk, Cloud Logging).
If passwords, tokens, or PII are in logs — they're now in your logging system, accessible to anyone with log access.

**Layer 1 — Fix in the application (preferred):**
The real fix is in code — never log sensitive fields.
Use structured logging and explicitly exclude sensitive keys:
```python
# WRONG
logger.info(f"Processing payment for {card_number}")

# RIGHT
logger.info("Processing payment", extra={"masked_card": f"****{card_number[-4:]}"})
```

**Layer 2 — Log scrubbing at collection:**
If you can't change the app immediately, scrub at the log shipper level.
Fluentd, Logstash, or Pub/Sub pipelines can redact patterns before storage.
Regex pattern to catch card numbers: `\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b`

**Layer 3 — Docker log driver configuration:**
```bash
docker run --log-driver=none myapp
```
Disables logging entirely — use only if you have application-level logging to a secure destination.

**Layer 4 — Restrict log access:**
In GCP Cloud Logging — restrict log viewer IAM permissions.
Only ops team with need-to-know gets access to production logs.
Audit log access — who viewed which logs.

**Layer 5 — Separate sensitive operations:**
Run payment processing in a separate container with stricter log controls.
Principle of least privilege applies to logging too.

**To say:**
'The right answer is fix it in the application — sensitive data should never be logged in the first place. While that fix is being developed, I'd add log scrubbing at the collection layer to redact patterns matching cards, tokens, or PII before they reach the centralized log store.'"

---

---

# SECTION 3 — NETWORKING SCENARIOS

---

## SCENARIO 8 — Basic
### "Two containers can't talk to each other. How do you fix it?"

**The answer:**

"Container-to-container communication depends on which network they're on.

**Default behavior:**
By default, containers on the bridge network can communicate by IP but NOT by name.
Containers on a custom network can communicate by container name — Docker provides built-in DNS.

**Diagnosis:**
```bash
# check which networks each container is on
docker inspect <container1> | grep NetworkMode
docker inspect <container2> | grep NetworkMode

# list all networks
docker network ls

# see which containers are on a network
docker network inspect <network_name>
```

**Fix 1 — Put both on the same custom network:**
```bash
docker network create myapp-net
docker run --name app --network myapp-net myapp
docker run --name db --network myapp-net postgres
```
Now: app can reach db by name `db:5432`

**Fix 2 — docker-compose handles this automatically:**
```yaml
version: '3'
services:
  app:
    build: .
    depends_on:
      - db
  db:
    image: postgres
```
docker-compose creates a network for all services. They reach each other by service name.

**Fix 3 — Link (legacy, avoid):**
`--link` flag works but is deprecated. Use custom networks instead.

**To say:**
'Two containers can't talk when they're on different networks or when you're trying to connect by IP after a restart. The fix is to put them on the same custom named network — then Docker's built-in DNS lets them reach each other by container name regardless of IP.'"

---

## SCENARIO 9 — Intermediate
### "Your container needs to be accessible on port 8080 from the host but it's not responding. What do you check?"

**VERDICT-7 scan:**
```
V → Was port binding changed recently?
E → Not accessible from host — is it accessible from inside?
R → (not resource)
D → (not dependency)
I → (not infra)
C → Port binding is a CONNECTIVITY issue ← this is exactly it
T → docker ps shows port mapping. netstat shows what's listening.
```

**The answer:**

"Port not responding from host = either port isn't bound, or the app inside isn't listening on the right interface.

**Check 1 — Is the port actually mapped?**
```bash
docker ps
```
Look for: `0.0.0.0:8080->8080/tcp`
If you see `8080/tcp` without the `0.0.0.0:8080->` part — port is exposed but not published.

**The difference:**
```bash
# EXPOSE in Dockerfile — documents the port, doesn't publish it
EXPOSE 8080

# -p flag publishes — makes it accessible from host
docker run -p 8080:8080 myapp

# format: host_port:container_port
docker run -p 80:8080 myapp  # host port 80 → container port 8080
```

**Check 2 — Is the app listening on the right interface?**
```bash
docker exec -it <container> netstat -tlnp
```
Look for: `0.0.0.0:8080` — listening on all interfaces (accessible)
If you see: `127.0.0.1:8080` — listening on localhost only (NOT accessible from host)

This is a very common issue in Python/Node apps:
```python
# WRONG — only accessible inside container
app.run(host='127.0.0.1', port=8080)

# RIGHT — accessible from host via port mapping
app.run(host='0.0.0.0', port=8080)
```

**Check 3 — Is something else using port 8080 on the host?**
```bash
netstat -tlnp | grep 8080    # on host
```
Fix: Use a different host port: `docker run -p 8081:8080 myapp`

**Check 4 — Firewall on host:**
Host firewall might be blocking the port even though Docker published it.
```bash
sudo ufw status    # Ubuntu
sudo firewall-cmd --list-ports   # RHEL/CentOS
```

**To say:**
'Two things to check: first, is the port actually published with -p flag — EXPOSE in Dockerfile doesn't make it accessible. Second, is the application listening on 0.0.0.0 not 127.0.0.1 — if the app only listens on localhost inside the container, it can't receive traffic routed from the host.'"

---

---

# SECTION 4 — STORAGE SCENARIOS

---

## SCENARIO 10 — Intermediate
### "Container data is being lost every time the container restarts. How do you fix it?"

**The answer:**

"Containers are ephemeral by design — the filesystem inside is lost when the container is removed. This is intentional for stateless apps but a problem for anything that needs to persist data.

**The solution — volumes:**

**Option 1 — Named volume (recommended for databases):**
```bash
docker volume create mydata
docker run -v mydata:/var/lib/postgresql/data postgres
```
Data lives in Docker-managed storage on the host.
Survives container removal, restart, and updates.
`docker volume ls` — list volumes
`docker volume inspect mydata` — see where it's stored

**Option 2 — Bind mount (recommended for development):**
```bash
docker run -v /home/ajith/app/data:/app/data myapp
```
Maps a host directory into the container.
Changes visible immediately on both sides.
Good for development — code changes reflect instantly.

**Option 3 — tmpfs mount (for sensitive temporary data):**
```bash
docker run --tmpfs /app/tmp myapp
```
In-memory, never written to disk.
Lost on restart — good for secrets that shouldn't persist.

**The key insight:**
```dockerfile
# Dockerfile — document which paths need persistence
VOLUME /app/data
```
This tells users of the image that this path contains important data.
docker-compose handles volumes automatically:
```yaml
services:
  db:
    image: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

**To say:**
'Containers are stateless by design — any data written inside the container's filesystem is lost when it's removed. The fix is to mount a volume to the path where the app writes data. Named volumes are best for production — data survives container recreation and Docker manages the storage location automatically.'"

---

---

# SECTION 5 — ADVANCED SCENARIOS

---

## SCENARIO 11 — Advanced
### "Your Docker image works fine but has 15 critical CVEs in the vulnerability scan. How do you fix it?"

**VERDICT-7 scan:**
```
V → When did these CVEs appear? New scan or existing image?
E → Which components are affected? OS packages? App dependencies?
R → (not resource)
D → Are the vulnerable packages actually used by the application?
I → (not infra)
C → (not connectivity)
T → trivy image <n> ← detailed CVE report with package name, version, fix version
```

**The answer:**

"CVEs in a Docker image are common — the question is whether they're exploitable in your context and how to fix them efficiently.

**Step 1 — Understand the CVE report:**
```bash
trivy image myapp:latest
```
Output shows: Package name, current version, CVE ID, severity, fixed version.

**Prioritize by exploitability:**
- CRITICAL or HIGH with network attack vector → fix immediately
- CVEs in packages your app never uses → lower priority
- CVEs with no fix available → document and mitigate differently

**Fix 1 — Update the base image (fixes OS-level CVEs):**
```dockerfile
# Instead of a specific old version
FROM python:3.11.0-slim

# Use latest patch version
FROM python:3.11-slim
```
Or rebuild with `--no-cache` to pull latest packages.

**Fix 2 — Update app dependencies:**
```bash
pip list --outdated    # see outdated packages
pip install --upgrade package-name
```
Update requirements.txt with fixed versions.

**Fix 3 — Switch to distroless or minimal base image:**
```dockerfile
# Distroless — no shell, no package manager, minimal attack surface
FROM gcr.io/distroless/python3
COPY app.py /app/
CMD ["/app/app.py"]
```
Distroless images have almost zero CVEs because there's almost nothing in them.

**Fix 4 — Multi-stage to remove build tools:**
Build tools (gcc, make) often carry CVEs but aren't needed at runtime.
Use multi-stage — they stay in stage 1 and never reach production.

**For packages with no fix available:**
Document the CVE, assess if the vulnerable code path is reachable.
Add compensating controls — network policy, container isolation.
Set a review date.

**Add scanning to CI pipeline:**
```yaml
- name: Scan image
  run: trivy image --exit-code 1 --severity CRITICAL myapp:latest
```
Pipeline fails on CRITICAL CVEs — nothing gets to production with critical vulnerabilities.

**To say:**
'I'd run trivy to get the detailed report, then separate OS-level CVEs from application dependency CVEs. Base image update fixes most OS CVEs immediately. For application dependencies I'd update requirements.txt with patched versions. Long term I'd switch to a distroless base image — minimal packages means minimal CVE surface.'"

---

## SCENARIO 12 — Advanced
### "Docker build in CI takes 20 minutes. Every single run. How do you get it to 3 minutes?"

**VERDICT-7 scan:**
```
V → Was caching ever set up? Is cache being invalidated every run?
E → CI pipeline — runners are stateless, cache doesn't persist between runs by default
R → Time is the resource being wasted
D → Are dependencies downloaded fresh every run?
I → (not infra)
C → (not connectivity)
T → Time each step in the build ← GitHub Actions shows this automatically
```

**The answer:**

"20 minutes every run = cache is either not set up or broken. Most Docker builds should be under 3 minutes with proper caching.

**Diagnose — which step takes the most time:**
In GitHub Actions, expand each step to see its duration.
Usually it's `pip install` or `npm install` — downloading all dependencies every run.

**Fix 1 — Correct Dockerfile layer order (most impactful):**
```dockerfile
# WRONG — code copy before dependencies
# Any code change = reinstall ALL dependencies
COPY . .
RUN pip install -r requirements.txt

# RIGHT — dependencies first, code after
# Dependency layer only rebuilds when requirements.txt changes
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .           # code changes only bust this layer
```

**Fix 2 — GitHub Actions layer caching:**
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
    tags: myapp:latest
```
`type=gha` uses GitHub Actions cache storage.
First run: 20 minutes. Subsequent runs: 2-3 minutes.

**Fix 3 — Cache pip/npm separately:**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-
```
Cache key includes hash of requirements.txt.
If requirements.txt unchanged: cache hit, skip download.
If requirements.txt changed: cache miss, download new packages.

**Fix 4 — Use a pre-built base image:**
Build a custom base image with all dependencies pre-installed.
Push to GCR. Use it as your FROM.
```dockerfile
# Your custom base with all deps pre-installed
FROM gcr.io/myproject/myapp-base:latest
COPY app.py .
CMD ["python", "app.py"]
```
App code changes don't trigger dependency reinstall.
Only rebuild base when requirements.txt changes.

**Expected results:**
- No cache: 20 minutes
- Layer order fixed: 8 minutes
- GitHub Actions cache: 2-3 minutes
- Pre-built base image: under 1 minute

**To say:**
'The biggest win is always Dockerfile layer order — put COPY requirements.txt and pip install before COPY of application code. This way dependency layer is cached and only app code rebuilds. Combined with GitHub Actions cache for Docker layers, you get from 20 minutes to 2-3 minutes without any other changes.'"

---

---

# MENTAL MODELS — DOCKER QUICK REFERENCE

```
BUILD problems  → docker build output, --no-cache, layer order, .dockerignore
RUNTIME problems → docker logs, docker inspect, exit codes, resource limits
NETWORK problems → docker network, port binding, 0.0.0.0 vs 127.0.0.1
STORAGE problems → volumes, bind mounts, ephemeral filesystem

Exit Code 0   = process finished (wrong for a server)
Exit Code 1   = application error
Exit Code 137 = OOMKilled
Exit Code 139 = segfault

Image size fix order:
1. Slim/alpine base image
2. Multi-stage builds
3. .dockerignore
4. Clean in same RUN layer
5. Distroless (advanced)

Port not working checklist:
1. -p flag used? (not just EXPOSE)
2. App listening on 0.0.0.0?
3. Host firewall blocking?
4. Port already in use on host?
```

---

## 5-Day Docker Practice Plan

| Day | Focus |
|---|---|
| Day 1 | Build scenarios 1-4 — say VERDICT scan first, then answer |
| Day 2 | Runtime scenarios 5-7 — focus on resource limits and logs |
| Day 3 | Network scenarios 8-9 — draw the network model, then explain |
| Day 4 | Storage + Advanced scenarios 10-12 |
| Day 5 | Full mock — close document, answer all 12 from memory |
