# pulse

A small Linux and network health checker, built in stages to learn shell scripting, Python, Linux and networking basics (and later Java, Docker and CI/CD).

## What it checks

- Disk usage
- Memory and load
- Reachability of a host (ICMP ping)
- DNS resolution
- TCP port connectivity

## Usage

Shell version:

```bash
chmod +x scripts/healthcheck.sh
./scripts/healthcheck.sh 1.1.1.1 example.com 443
```

Python version (prints a JSON report):

```bash
python3 pulse.py --host 1.1.1.1 --domain example.com --port 443
```

Tests:

```bash
pip install pytest
pytest
```

## Roadmap

- [x] Phase 1: shell script (`scripts/healthcheck.sh`)
- [ ] Phase 2: Python version with JSON output (`pulse.py`), add a `--config` YAML file with several hosts
- [ ] Phase 3: add `pytest` tests and `shellcheck` to a GitHub Actions workflow
- [ ] Phase 4: Dockerfile, run the checker in a container
- [ ] Phase 5: small Java service (Spring Boot or plain `HttpServer`) that receives the JSON reports on `POST /reports`
- [ ] Phase 6: deploy with Docker Compose, then Terraform

## What I learned

Keep a short log here as you go: commands, mistakes, fixes.

| Date | Topic | Notes |
|------|-------|-------|
|      |       |       |
