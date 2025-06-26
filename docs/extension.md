# Anomaly Detection to Generate Alert Rules
Modern cloud-native applications generate vast amounts of metrics data that require sophisticated monitoring strategies to ensure system reliability and performance. Traditional alerting approaches rely heavily on manually crafted threshold-based rules that often fail to capture the complex, dynamic behavior patterns inherent in distributed systems. This extension proposal presents an intelligent anomaly detection framework that automatically generates contextual Prometheus alert rules by analyzing historical failure patterns and system behavior, addressing a critical gap in proactive monitoring capabilities.

## Issues with current setup


The current monitoring setup relies predominantly on manually written Prometheus alerts that create several critical operational challenges. These static, threshold-based rules generate alert fatigue through excessive false positives. Here is a simple alert rule to highlight the issue:

```yaml
- alert: HighErrorRate
    expr: rate(http_requests_total{status_code!="200"}[1m]) > 0.1
    for: 1m
```
In this alert, it is hard to determine the correct threshold (`0.1`) as sometimes due to temporary service failure, having a higher threshold would be appropriate. Similarly in case of rate-limiting, obtaining an error code may be part of how the deployment behaves. So coming up with correct tags and thresholds often involves manual intervention. If not properly configured, leads to desensitization where critical issues may be missed among the noise. Incomplete failure coverage represents another significant limitation. Manual rules cannot anticipate the complex failure patterns that emerge in distributed systems, particularly in Istio service mesh environments where traffic routing, circuit breakers, and service dependencies create intricate failure cascades. Static thresholds miss subtle performance degradations that precede complete outages, resulting in reactive rather than proactive incident response. The prometheus architecture shown below helps us see these limitations

![Prometheus Architecture](images/architecture.svg)

The aggregated metrics grows with the number of jobs deployed. The maintenance overhead grows exponentially with system complexity as combination of metrics could trigger a failure. As our application evolves through continuous experimentation and canary deployments, alert rules require constant updates to remain relevant. This creates a significant operational burden that diverts engineering resources from feature development to monitoring maintenance.

## Background
We now look at two approaches that have been used in practice so as to improve system reliability and failure coverage. 

### 1. Borgmon by Google [[1]](#1)
Google's Borgmon system, documented in their SRE practices, introduced the concept of white-box monitoring that focuses on symptoms rather than causes. Borgmon pioneered the use of time-series data collection with sophisticated alerting rules that could understand service behavior patterns. However, even Google's approach requires manual rule creation by experienced SREs who must translate operational knowledge into monitoring expressions.

The Four Golden Signals (latency, traffic, errors, saturation) provide a framework for meaningful alerts, but implementing these signals still requires manual threshold configuration and rule maintenance. Google's experience shows that effective alerting requires deep understanding of service behavior patterns - knowledge that could be automatically extracted through anomaly detection.

### 2. Chaos Engineering by Netflix [[2]](#2)
Netflix's Chaos Engineering methodology systematically injects failures to understand system behavior under adverse conditions. Their Chaos Monkey and related tools revealed failure patterns that informed more intelligent monitoring strategies. By observing how systems respond to controlled failures, Netflix developed insights into early warning indicators and cascading failure patterns.

However, translating chaos experiment results into actionable alert rules remains a manual process requiring expert analysis. Netflix engineers must observe experiment outcomes, identify meaningful patterns, and craft corresponding monitoring rules - a process that could be automated through machine learning approaches.

## Proposed Solution
We now propose implementing an Anomaly Detection Framework that automatically generates contextual Prometheus alert rules by analyzing historical system behaviour, chaos experiment results and failure patterns. We address the identified shortcomings through four integrated components:

### 1. Historical Pattern Analysis Engine
This component systematically analyzes our Istio service mesh metrics, application performance data and incident reports to identify recurring failure patterns [[3]](#3). It also specifically analyzes continuous experimentation data from canary deployments, extracting patterns that indicate when experiments are failing or succeeding. This creates experiment-aware alerting that can distinguish between normal A/B test variations and genuine system issues.

### 2. Chaos-Informed Rule Generation
Integrating with our Istio traffic management capabilities, this system uses controlled failure injection to understand normal recovery patterns. When traffic shifts during canary releases, the system learns expected behaviour patterns and generates rules tat can distinguish between planned traffic management and unplanned failures.

### 3. Service Mesh-Aware Correlation
This component understands our Istio service mesh topology and can correlate alerts across service boundaries. Using DestinationRules and VirtualServices configuration, it builds a dependency graph that enables intelligent alert correlation.

### 4. Continuous Learning Integration
The framework continuously learns from our continuous experimentation results, automatically adjusting alert sensitivity based on experimental contexts. During canary deployments, it temporarily adjusts thresholds to account for expected variations while maintaining sensitivity to genuine issues.

We highlight how these four components can work together with the Prometheus Server in the figure below.

![Proposed Architecture](images/Proposed-Architecture.svg)

## Experimental Design
To verify the effectiveness of the proposed architecture, we can use a controlled A/B testing approach within our existing infrastructure.

### 1. Baseline measurement
Deploy current manual alerts alongside the new system for 30 days, measuring all metrics without acting on anomaly detection alerts

### 2. Gradual Rollout
Implement pattern-based alerts for 25% of services, comparing performance against manual alerts on remaining services.

### 3. Chaos Engineering Validation
Use controlled failure injection to test detection accuracy and response times.

### 4. Continuous Experimentation Integration
Validate the system correctly handles canary deployment scenarios without generating false alert.

The experimental design can be conducted with the use of the following metrics

| Metric | Description |
| ----| ---- |
| Mean Time to Detect | Compare detection speed between current manual alerts and pattern-based rules using historical incident data |
| Alert Precision and Recall | False Positive Reduction & True Positive Coverage |
| Investigation Time | Track time from alert to root cause identification |
| Maintenance Overhead | Measure engineering hours spent on alert rule maintenance |

## References
<a id="1">[1]</a>
Jamie Wilkinson. Practical Alerting from Time-Series Data. [Google SRE Book](https://sre.google/sre-book/practical-alerting/)

<a id="2">[2]</a>
Alie Basiri, Niosha Behman. Chaos Engineering. [Chaos Engineering, IEEE Software](https://arxiv.org/pdf/1702.05843)

<a id="3">[3]</a>
Tanja Hagemann & Katerina Katsarou. [A Systematic Review on Anomaly Detection for Cloud Computing Environments](https://dl.acm.org/doi/fullHtml/10.1145/3442536.3442550) 
