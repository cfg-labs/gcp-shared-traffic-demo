// traffic-gen - probe an arbitrary number of HTTPS hosts at a target RPS and
// record every response to a JSONL file. Used by demo-rotate.sh to prove the
// zero-incident rotation property (Article 10 capstone).
//
// Build: go build -o traffic-gen traffic-gen.go
// Usage: traffic-gen --duration=600s --rps=10 --output=/tmp/out.json host1 host2 ...

package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

type Result struct {
	Timestamp time.Time `json:"ts"`
	Host      string    `json:"host"`
	Status    int       `json:"status"`
	LatencyMs float64   `json:"latency_ms"`
	Err       string    `json:"err,omitempty"`
}

func probe(host string, results chan<- Result) {
	start := time.Now()
	resp, err := http.Get("https://" + host + "/")
	r := Result{Timestamp: start, Host: host, LatencyMs: float64(time.Since(start).Microseconds()) / 1000.0}
	if err != nil {
		r.Err = err.Error()
	} else {
		r.Status = resp.StatusCode
		resp.Body.Close()
	}
	results <- r
}

func main() {
	duration := flag.Duration("duration", 10*time.Minute, "total run duration")
	rps := flag.Int("rps", 10, "requests per second per host")
	output := flag.String("output", "/tmp/traffic.json", "output JSONL file")
	flag.Parse()
	hosts := flag.Args()
	if len(hosts) == 0 {
		log.Fatal("at least one host required")
	}

	f, err := os.Create(*output)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	enc := json.NewEncoder(f)

	results := make(chan Result, 1024)
	done := make(chan struct{})

	go func() {
		for r := range results {
			_ = enc.Encode(r)
		}
		close(done)
	}()

	var wg sync.WaitGroup
	interval := time.Second / time.Duration(*rps)
	deadline := time.Now().Add(*duration)

	for _, host := range hosts {
		wg.Add(1)
		go func(h string) {
			defer wg.Done()
			ticker := time.NewTicker(interval)
			defer ticker.Stop()
			for {
				if time.Now().After(deadline) {
					return
				}
				<-ticker.C
				probe(h, results)
			}
		}(host)
	}

	wg.Wait()
	close(results)
	<-done
}
