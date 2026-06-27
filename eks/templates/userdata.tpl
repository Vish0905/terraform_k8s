%{ if node_ami_type == "amazon-linux-2023" ~}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_ca}
    cidr: 10.100.0.0/16

--BOUNDARY--
%{ else ~}
#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_extra_args}
%{ endif ~}
