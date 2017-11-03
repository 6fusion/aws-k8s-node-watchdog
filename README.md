# aws-k8s-node-watchdog
Used to monitor AWS instance health and shutdown instances if they become unavailable.


### Background
Both AWS and Kubernetes have built-in support for monitoring the health of instances (nodes).
However, problems can arise when nodes pass AWS health checks, but are unresponsive to Kubernetes.
A primary example of this is memory exhaustion on the node; the instance's kernel will still respond to
AWS health checks, but not be able to fullfill Kubernetes requests.

Kubernetes will flag nodes in this state with a status of `Unknown` and begin to schedule effected
pods onto other nodes. However, if EBS volumes required by an effected pod are mounted on an
unresponsive node, the pod will not be scheduable, since its requisite volume mounts cannot be fulfilled.

A simple solution to free the volume is simply to mark the AWS instance as `Unhealthy`. Once informed, AWS
will deploy a new worker instance and terminate the `Unhealthy` one. This frees any volumes mounted to the
unresponsive instance, and allows Kubernetes to redeploy "stuck" pods, once their volumes are freed.

### Deployment
The container does not require any special environment variables or AWS credentials (if an appropriate IAM role is
associated with the cluster).

Authorization to interact with the Kubernetes API is obtained through the usual Kubernetes-injected variables and token.

The following environment variables are available to customize the behavior of the health check:

| Variable  | Purpose |
| ------------- | ------------- |
| AWS_ACCESS_KEY_ID | AWS access key (if not using IAM) |
| AWS_SECRET_ACCESS_KEY | AWS secret key (if not using IAM) |
| CHECK_INTERVAL | The interval, in seconds, between health checks. Defaults to 30 seconds. |
| DEBUG | Set to `true` to see verbose output from the watchdog process |
| FAIL_COUNT | The number of times a node is seen with the status of *Unknown*. Defaults to 2. |

Note: The failure count for a node is reset if the node leaves the state of *Unknown*.

To deploy:
```kubectl apply -f kubernetes.yml```
