# hello-kanister

Trivial examples of application-level backup and restore using Kanister blueprints

## Developing

Fork and clone this repository, then navigate to the project root and follow the instructions below.

### Install pre-commit hook \(optional\)

The pre-commit hook runs formatting and sanity checks such as `tofu fmt` to reduce the chance of accidentally submitting badly formatted code that would fail CI.

```bash
ln -s ../../hooks/pre-commit ./.git/hooks/pre-commit
```

### Prerequisites

1. An [AWS](https://aws.amazon.com/) account
1. Valid AWS credentials for an IAM administrator account - see [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for details
1. [OpenTofu](https://opentofu.org/) v1.7.2 or later
1. A Kubernetes cluster - spin one up with [kind](https://kind.sigs.k8s.io/) if in doubt
1. Cluster-admin access to the Kubernetes cluster with `kubectl`
1. [Helm](https://helm.sh/)
1. The [Kanister operator](https://docs.kanister.io/install.html) installed on our Kubernetes cluster

### Create the S3 bucket for storing our Kanister backups

Create the S3 bucket for storing our Kanister backups using OpenTofu:

```bash
tofu init
tofu plan
tofu apply
```

Supported variables:

| Name | Type | Required | Default value | Description |
| --- | --- | --- | --- | --- |
| `profile` | `string` | - | `"default"` | The profile to assume from the [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) |
| `region` | `string` | - | `"ap-east-1"` | The AWS region to assume |

### Running the time logger example

The time logger example is based on the [Kanister tutorial](https://docs.kanister.io/tutorial.html).

First create a deployment which appends a timestamp to the log file at `/var/log/time.log` every second:

```bash
kubectl create -f time-logger/deployment.yaml
```

Wait for the pods in our deployment to become ready:

```bash
kubectl wait \
    --for=condition=Ready \
    pods \
    -l app=time-logger \
    --timeout=180s
```

Sample output:

```text
pod/time-logger-777955ffb4-q6bmp condition met
```

The log file is streamed to STDOUT via the `busybox` container:

```bash
kubectl logs -l app=time-logger -c busybox
```

Sample output:

```text
Sat Jun  8 13:56:27 UTC 2024
Sat Jun  8 13:56:28 UTC 2024
Sat Jun  8 13:56:29 UTC 2024
Sat Jun  8 13:56:30 UTC 2024
Sat Jun  8 13:56:31 UTC 2024
Sat Jun  8 13:56:32 UTC 2024
Sat Jun  8 13:56:33 UTC 2024
Sat Jun  8 13:56:34 UTC 2024
Sat Jun  8 13:56:35 UTC 2024
Sat Jun  8 13:56:36 UTC 2024
```

Create the ConfigMap and Secret which contain our bucket URL and AWS credentials for accessing our bucket:

```bash
kubectl create -f time-logger/configmap.yaml
kubectl create -f time-logger/secret.yaml
```

Now create our Kanister blueprint. The blueprint defines backup and restore actions for our log file but does not execute them.

```bash
kubectl create -f time-logger/blueprint.yaml
```

To run the backup action defined in our blueprint, create an ActionSet invoking that action.

```bash
kubectl create -f time-logger/backup-actionset.yaml
```

Wait a few seconds and confirm that the backup ActionSet has entered a "complete" state:

```bash
kubectl -n kanister get actionsets.cr.kanister.io
```

Sample output:

```text
NAME                          PROGRESS   SIZEDOWNLOADEDB   SIZEUPLOADEDB   ESTIMATEDDOWNLOADSIZEB   ESTIMATEDUPLOADSIZEB   RUNNING PHASE   LAST TRANSITION TIME   STATE
time-logger-s3backup-n6h8q    100                                                                                                          2024-06-08T13:51:24Z   complete
```

Confirm that a log file `time-logger/XXXX-XX-XX` was uploaded to S3 as well.

Optionally run the restore ActionSet as well and confirm that it runs to completion, though you'll probably need to edit the `restoreDate` beforehand which is hardcoded to `2024-06-08` in the given template:

```bash
kubectl create -f time-logger/restore-actionset.yaml
```

Now view the contents of the log file `/var/log/time.log` within the pod and observe that log file was overwritten by the restore operation.

## License

[MIT](./LICENSE)
