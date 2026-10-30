#!/usr/bin/env python3
"""pulse - a tiny Linux and network health checker (Python version).

Standard library only. Prints a JSON report and exits 1 if any check failed.
"""

import argparse
import json
import os
import shutil
import socket
import subprocess
import sys


def check_disk(path="/", limit=80):
    usage = shutil.disk_usage(path)
    percent = round(usage.used / usage.total * 100, 1)
    return {
        "check": "disk",
        "ok": percent < limit,
        "detail": f"{percent}% used on {path} (limit {limit}%)",
    }


def check_load():
    load1, _, _ = os.getloadavg()
    cores = os.cpu_count() or 1
    return {
        "check": "load",
        "ok": load1 < cores,
        "detail": f"load {load1:.2f} on {cores} cores",
    }


def check_ping(host):
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "2", host],
            capture_output=True,
            timeout=5,
        )
        reachable = result.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        reachable = False
    return {"check": "ping", "ok": reachable, "detail": f"ping {host}"}


def check_dns(domain):
    try:
        address = socket.gethostbyname(domain)
        return {"check": "dns", "ok": True, "detail": f"{domain} -> {address}"}
    except socket.gaierror:
        return {"check": "dns", "ok": False, "detail": f"cannot resolve {domain}"}


def check_tcp(host, port, timeout=3):
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return {"check": "tcp", "ok": True, "detail": f"{host}:{port} reachable"}
    except OSError:
        return {"check": "tcp", "ok": False, "detail": f"{host}:{port} unreachable"}


def run_checks(host, domain, port):
    return [
        check_disk(),
        check_load(),
        check_ping(host),
        check_dns(domain),
        check_tcp(domain, port),
    ]


def main(argv=None):
    parser = argparse.ArgumentParser(description="Linux and network health checker")
    parser.add_argument("--host", default="1.1.1.1", help="host to ping")
    parser.add_argument("--domain", default="example.com", help="domain to resolve and connect to")
    parser.add_argument("--port", type=int, default=443, help="TCP port to test")
    args = parser.parse_args(argv)

    results = run_checks(args.host, args.domain, args.port)
    print(json.dumps({"results": results}, indent=2))
    return 0 if all(r["ok"] for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
