[![Release](https://img.shields.io/github/release/maorfr/skbn.svg)](https://github.com/gruberdev/skbn/releases)
[![Travis branch](https://img.shields.io/travis/maorfr/skbn/master.svg)](https://travis-ci.org/maorfr/skbn)
[![Docker Pulls](https://img.shields.io/docker/pulls/maorfr/skbn.svg)](https://hub.docker.com/r/maorfr/skbn/)
[![Go Report Card](https://goreportcard.com/badge/github.com/gruberdev/skbn)](https://goreportcard.com/report/github.com/gruberdev/skbn)
[![license](https://img.shields.io/github/license/maorfr/skbn.svg)](https://github.com/gruberdev/skbn/blob/master/LICENSE)

# Skbn

Skbn is a tool for copying files and directories between Kubernetes and cloud storage providers. It is named after the 1981 video game [Sokoban](https://en.wikipedia.org/wiki/Sokoban).
Skbn uses an in-memory buffer for the copy process, to avoid excessive memory consumption.
Skbn currently supports the following providers:

* AWS S3
* Minio S3
* Azure Blob Storage
* Google Cloud Storage

## Install

### Prerequisites

1. git
2. [dep](https://github.com/golang/dep)

### From a release

Download the latest release from the [Releases page](https://github.com/gruberdev/skbn/releases) or use it with a [Docker image](https://hub.docker.com/r/maorfr/skbn)

### From source

```
mkdir -p $GOPATH/src/github.com/maorfr && cd $_
git clone https://github.com/gruberdev/skbn.git && cd skbn
make
```

## Usage

### Copy files from Kubernetes to S3

```
skbn cp \
    --src k8s://<namespace>/<podName>/<containerName>/<path> \
    --dst s3://<bucket>/<path>
```

### Copy files from S3 to Kubernetes

```
skbn cp \
    --src s3://<bucket>/<path> \
    --dst k8s://<namespace>/<podName>/<containerName>/<path>
```

### Copy files from Kubernetes to Azure Blob Storage

```
skbn cp \
    --src k8s://<namespace>/<podName>/<containerName>/<path> \
    --dst abs://<account>/<container>/<path>
```

### Copy files from Azure Blob Storage to Kubernetes

```
skbn cp \
    --src abs://<account>/<container>/<path> \
    --dst k8s://<namespace>/<podName>/<containerName>/<path>
```

### Copy files from Kubernetes to Google Cloud Storage

```
skbn cp \
    --src k8s://<namespace>/<podName>/<containerName>/<path> \
    --dst gcs://<bucket>/<path>
```

## Advanced usage

### Copy files from source to destination in parallel

```
skbn cp \
    --src ... \
    --dst ... \
    --parallel <n>
```
* `n` is the number of files to be copied in parallel (for full parallelism use 0)

### Set in-memory buffer size

Skbn copies files using an in-memory buffer. To control the buffer size:

```
skbn cp \
    --src ... \
    --dst ... \
    --buffer-size <f>
```
* `f` is the in-memory buffer size (in MB) to use for files copy. This flag should be used with caution when used in conjunction with `--parallel`
* The default value for `buffer-size` is 6.75 MB, and was decided based on benchmark

### Minio S3 support

Skbn supports file copy from and to a Minio S3 endpoint. To let skbn know how your minio is configured, you can set the following environment variables:

```
AWS_ACCESS_KEY_ID=<your username>
AWS_SECRET_ACCESS_KEY=<your password>
AWS_S3_ENDPOINT=http(s)://<host>:<port>
AWS_S3_NO_SSL=true # disables SSL
AWS_S3_FORCE_PATH_STYLE=true # enforce path style bucket access
```

## Added bonus section

### Copy files from S3 to Azure Blob Storage

```
skbn cp \
    --src s3://<bucket>/<path> \
    --dst abs://<account>/<container>/<path>
```

### Copy files from Azure Blob Storage to S3

```
skbn cp \
    --src abs://<account>/<container>/<path> \
    --dst s3://<bucket>/<path>
```

### Copy files from Kubernetes to Kubernetes

```
skbn cp \
    --src k8s://<namespace>/<podName>/<containerName>/<path> \
    --dst k8s://<namespace>/<podName>/<containerName>/<path>
```

### Copy files from S3 to S3

```
skbn cp \
    --src s3://<bucket>/<path> \
    --dst s3://<bucket>/<path>
```

### Copy files from Azure Blob Storage to Azure Blob Storage

```
skbn cp \
    --src abs://<account>/<container>/<path> \
    --dst abs://<account>/<container>/<path>
```

## Credentials


### Kubernetes

Skbn tries to get credentials in the following order:
1. if `KUBECONFIG` environment variable is set - skbn will use the current context from that config file
2. if `~/.kube/config` exists - skbn will use the current context from that config file with an [out-of-cluster client configuration](https://github.com/kubernetes/client-go/tree/master/examples/out-of-cluster-client-configuration)
3. if `~/.kube/config` does not exist - skbn will assume it is working from inside a pod and will use an [in-cluster client configuration](https://github.com/kubernetes/client-go/tree/master/examples/in-cluster-client-configuration)


### AWS

Skbn uses the default AWS [credentials chain](https://docs.aws.amazon.com/sdk-for-go/v1/developer-guide/configuring-sdk.html).
In addition, the `AWS_REGION` environment variable should be set (default is `eu-central-1`).

### Azure Blob Storage

Skbn uses `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_ACCESS_KEY` environment variables for authentication.

### Google Cloud Storage

Skbn uses Google [Application Default Credentials](https://cloud.google.com/docs/authentication/production). 
Basically, it will first look for the `GOOGLE_APPLICATION_CREDENTIALS` environment variable. If it is not defined, it will look for the default service account, or throw an error if none is configured. 

## Examples

1. [In-cluster example](/examples/in-cluster)
2. [Code example](/examples/code)
