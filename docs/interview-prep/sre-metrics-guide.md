# 📊 Interview Guide: SRE & The Four Golden Signals

In SRE (Site Reliability Engineering) interviews, you will inevitably be asked: *"Which metrics do you prioritize when monitoring a microservices architecture?"*

This guide provides a "Senior-level" response based on the **Four Golden Signals** (from the Google SRE Book) as implemented in this project.

---

## 1. Latency (The "Time" Signal)
*   **Definition**: The time it takes to service a request.
*   **Project Implementation**: We use **Prometheus Histograms** to track the duration of every HTTP request.
*   **Interview Talk**: *"I don't just look at average latency—it's misleading. I monitor **P95 and P99 percentiles** on our Grafana dashboard. This allows us to identify 'Tail Latency'—the 1% of users experiencing a 5-second delay even if the average is 200ms. If P99 spikes, I immediately correlate it with our Cloud Trace waterfall to see if the delay is in the Catalog service or the Postgres database query."*

## 2. Traffic (The "Demand" Signal)
*   **Definition**: A measure of how much demand is being placed on your system.
*   **Project Implementation**: Measured via `http_requests_total` counter in Prometheus.
*   **Interview Talk**: *"Traffic is our leading indicator for scaling. I configured our **Horizontal Pod Autoscaler (HPA)** to watch the Request-Per-Second (RPS) rate. During our flash sale simulation, we saw traffic jump from 10 to 500 RPS. Because I tuned the HPA stabilization window to 30 seconds, the cluster provisioned new replicas before the latency could degrade."*

## 3. Errors (The "Failure" Signal)
*   **Definition**: The rate of requests that fail, either explicitly (e.g., HTTP 500s) or implicitly (e.g., a 200 with incorrect data).
*   **Project Implementation**: Calculated as a percentage: `sum(rate(errors))/sum(rate(total))`.
*   **Interview Talk**: *"Errors are the primary input for our **SLO Burn Rate alerts**. If the Payment service error rate exceeds 0.1% for more than 5 minutes, it triggers a P0 page. I specifically track the ratio of 5xx errors to total traffic. If this ratio climbs, I use our structured logs in **Loki** to filter for the exact Trace ID causing the failure, allowing us to find the root cause in seconds rather than digging through raw text logs."*

## 4. Saturation (The "Fullness" Signal)
*   **Definition**: How "full" your service is. A measure of the most constrained system resource.
*   **Project Implementation**: Monitored via CPU/Memory usage and HPA replica limits.
*   **Interview Talk**: *"Saturation tells us when we are reaching a breaking point. On GKE Autopilot, I monitor pod CPU and Memory requests versus the actual usage. But critical saturation for us is often the **Database Connection Pool**. If our microservices hit their max connection limit to Cloud SQL, latency spikes even if CPU is low. I track 'Active Connections' as a custom metric to ensure we don't saturate the database during peak traffic."*

---

## 💡 Pro-Tip for the Interview:
When they ask about these, always tie them together: *"I use **Latency** to see the user impact, **Traffic** to understand the cause of that impact, **Errors** to confirm service failure, and **Saturation** to predict when the system will fail next."*
