#!/bin/bash
kubectl create namespace argocd
kubectl apply -n argocd -f install-argocd.yaml
