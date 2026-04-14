#!/usr/bin/env python3
"""Summarize a traffic-gen JSONL output for the zero-incident rotation demo."""
import json
import sys
from collections import defaultdict


def main(path: str) -> None:
    by_host = defaultdict(lambda: {"total": 0, "non_2xx": 0, "errors": 0, "latencies": []})
    with open(path, encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            r = json.loads(line)
            h = r["host"]
            by_host[h]["total"] += 1
            if r.get("err"):
                by_host[h]["errors"] += 1
                continue
            by_host[h]["latencies"].append(r["latency_ms"])
            if not (200 <= r["status"] < 300):
                by_host[h]["non_2xx"] += 1

    print(f"{'HOST':<50} {'TOTAL':>8} {'NON-2xx':>8} {'ERR':>6} {'P50':>8} {'P95':>8} {'P99':>8}")
    for h, d in sorted(by_host.items()):
        lats = sorted(d["latencies"])
        p50 = lats[int(len(lats) * 0.50)] if lats else 0.0
        p95 = lats[int(len(lats) * 0.95)] if lats else 0.0
        p99 = lats[int(len(lats) * 0.99)] if lats else 0.0
        print(f"{h:<50} {d['total']:>8} {d['non_2xx']:>8} {d['errors']:>6} {p50:>8.1f} {p95:>8.1f} {p99:>8.1f}")

    total_non_2xx = sum(d["non_2xx"] + d["errors"] for d in by_host.values())
    print(f"\nZero-incident: {'PASS' if total_non_2xx == 0 else f'FAIL ({total_non_2xx} bad responses)'}")


if __name__ == "__main__":
    main(sys.argv[1])
