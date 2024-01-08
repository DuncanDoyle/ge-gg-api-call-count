# Gloo API Call Counting

The objective of this project is to determine the Envoy Prometheus metrics and query that should/could be used to determine the number of API calls that have been made to the Gloo Edge/Gloo Gateway Envoy proxy.

Although probably the most accurate way to count API calls is via the Envoy access-log, being able to do this via Prometheus metrics allows one to count the number of API calls without having to setup access-logging, parsing, storage and analysis.

## Setup for Gloo Edge
This project assumes a:
- An existing Gloo Edge 1.15+ setup with ExtAuth and RateLimiting.
- The `glooctl` CLI available on the terminal's PATH.

You will find a [`setup-ge.sh`](setup/setup-ge-test.sh) script in the `setup` directory of this project. Running this script will:
- Install the HTTPBin application on your Gloo Edge environment.
- Configure ExtAuth and RateLimiting for our tests.
- Create 2 API-Keys to be used by our tests.
- Deploy the a VirtualService for our HTTPBin application.


## Test
We use [Apache JMeter](https://jmeter.apache.org/) to define and run our tests. The `tests` directory contains a test-script, [`run-jmeter-tests.sh`](tests/run-jmeter-tests.sh) that will run the following tests:
- Call various endpoints on the HTTPBin application with a correct API-Key
- Call various endpoints on the HTTPBin application with an incorrect API-Key (forcing ExtAuth errors).
- Call various endpoints on the HTTPBin aplication with the "rate-limiting" API-Key, which will cause requests that are executed with this API-Key to be rate-limited at some point.
- Call various endpoints on the HTTPBin aplication with an HTTP header that will cause the requests to hit the WAF policy and be rejected.
- Call non-existing paths on the HTTPBin application, forcing 404s from the HTTPBin application.
- Call non-existing paths on the Gloo Edge proxy, forcing 404s on Gloo Edge.

The results will be captured in `jtl` (JMeter Test Log) file, which will be immediately analyzed using the `analyze-jmeter-results.sh` script. This will display the number of calls made, number of responses per HTTP response code, etc. We can use this information to compare it with the metrics gathered by Prometheus.

## Prometheus metrics
To fetch the Prometheus metrics, first make the Prometheus API endpoint accessible from your local machine. This can be done with the [`port-forward-gloo-system-prometheus.sh`](setup/port-forward-gloo-system-prometheus.sh) script in the `setup` directory.

With Prometheus accessible from your local system, use the [`get-prom-metrics.sh`](tests/get-prom-metrics.sh) script in the `tests` directory to fetch 10 minutes of various Gloo Edge Envoy metrics that could be used to determine the number of API calls made to the Gloo Edge Envoy proxy.

## Resetting the Redis Rate-Limit cache
The `setup` directory contains a script, [`reset-redis.sh`](setup/reset-redis.sh), that will completely wipe the Redis cache. This allows us to reset the rate-limiting data, and as such, allow our tests to run from a clean environment, as deterministically as possible.

## Documentation
The [envoy-useful-api-call-count.adoc](envoy-useful-api-call-count.adoc) file contains a list of possible envoy metrics, including comments, that could be used to count the number of API calls to the Gloo Edge Envoy proxy.

## Results
So far, it seems that the Cluster Upstream RQ metrics (i.e. `envoy_cluster_upstream_rq`) gives a good representation of the number of API calls that have been made. From our tests, there are currently 2 types of calls that are not represented in these metrics:
- API calls filtered by the WAF policy. The WAF policy returns an error response with response code 418 (i.e "I'm a teapot", to explicitly distinguish it from other errors), and these 418 codes are not found in any of the metrics.
- API calls that are trying to reference non-existing contexts/paths on the Gloo Edge proxy. These calls result in 404s, but are not represented in the metrics (note that 404s of upstream endpoints are represented in the metrics).
