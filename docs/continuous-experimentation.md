# Continuous Experimentation: Model Response Time Optimization

## Hypothesis
**Version v2 of the model service will reduce average response time by 20% while maintaining prediction accuracy above 90% through optimized prediction threshold (0.65 vs 0.75).**

## Experiment Design
- **Control Group (v1)**: Current model service with threshold 0.75 (90% traffic)
- **Treatment Group (v2)**: Optimized model service with threshold 0.65 (10% traffic)
- **Duration**: 7 days
- **Sample Size**: 1000+ requests per version daily

## Metrics Tracked
1. **Response Time**: `num_requests` histogram (P95 and P50 percentiles)
2. **Request Rate**: `istio_requests_total` by version
3. **Error Rate**: `istio_requests_total{response_code=~"5.."}` 
4. **Traffic Distribution**: Percentage split verification

## Decision Criteria
**Accept v2 if:**
- P95 response time ≤ 400ms (20% improvement from 500ms baseline)
- Error rate increase ≤ 1%
- Traffic distribution maintains 90/10 split
- No degradation in user experience

## Implementation Details
- **Sticky Sessions**: Implemented via `consistentHash` on `X-User` header
- **Canary Routing**: 90/10 split using Istio VirtualService weights
- **Version Consistency**: DestinationRules ensure consistent model-app version pairing
- **Experiment Targeting**: `X-Experiment: canary` header for direct v2 access

## Results Analysis
The Grafana dashboard provides real-time comparison of:
- Request rate distribution between versions
- Response time percentiles (P95/P50)
- Error rate comparison
- Traffic distribution verification

![Experiment Dashboard](screenshots/experiment-metrics.png)

## Decision Process
1. **Monitor for 7 days** to collect sufficient data
2. **Analyze P95 response times** - accept if consistently ≤ 400ms
3. **Check error rates** - reject if increase > 1%
4. **Verify sticky sessions** - ensure consistent user routing
5. **Make data-driven decision** based on dashboard metrics

The experiment enables safe evaluation of model optimizations while maintaining user experience through sticky sessions and gradual rollout.
