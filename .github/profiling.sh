#!/bin/bash
set -e

cd charts
tar -xf openmrs*
ls
rm openmrs*.tgz

sed "s/ports:/& \n    - port: 10001\n      targetPort: 10001\n      protocol: TCP\n      name: '10001'/" ./openmrs/templates/service.yaml > ./openmrs/templates/service_performance.yaml
rm ./openmrs/templates/service.yaml

helm package openmrs openmrs && rm -rf openmrs
cd ../

INGRESS_DNS=$(kubectl -n ingress-nginx  get svc ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
          jq --arg ingress_dns "$INGRESS_DNS" \
             --arg environment_dns "profiling.lite.mybahmni.in" \
             '.Changes[].ResourceRecordSet.AliasTarget.DNSName = $ingress_dns | .Changes[0].ResourceRecordSet.Name = $environment_dns | .Changes[1].ResourceRecordSet.Name = "payments-"+$environment_dns' \
              aws/route53/lite.mybahmni.in.json > recordset

# ( echo 'apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: profiler-ingress
#   labels:
#     environment: performance
#   annotations:
#     nginx.ingress.kubernetes.io/configuration-snippet: |
#       add_header Set-Cookie "reporting_session=$cookie_JSESSIONID;Path=/;Max-Age=86400";
#     nginx.ingress.kubernetes.io/proxy-body-size: 7m
# spec:
#   ingressClassName: nginx
#   rules:
#     - host: profiling.lite.mybahmni.in
#       http:
#         paths:
#           - path: /
#             pathType: Prefix
#             backend:
#               service:
#                 name: openmrs
#                 port:
#                   number: 10001') > ./templates/profiling_ingress.yaml

