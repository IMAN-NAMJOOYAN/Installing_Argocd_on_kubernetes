# Installing_Argocd_on_kubernetes

![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/5b561788-c9ea-4404-ba48-f506a52474b7)

*ArgoCD* is an open-source declarative, GitOps continuous delivery (CD) tool for Kubernetes. It helps automate and simplify the deployment and management of applications on Kubernetes clusters by allowing you to define your application configurations in a Git repository. ArgoCD continuously monitors the Git repository, detects changes in your application configurations, and deploys those changes to your Kubernetes clusters, ensuring that the actual cluster state matches the desired state defined in the Git repository.

Key features and components of ArgoCD include:

1. **Declarative Configuration**: ArgoCD uses declarative YAML manifests to define the desired state of your applications and their dependencies, making it easy to manage and version control your application configurations.

2. **GitOps Workflow**: ArgoCD follows the GitOps workflow, where the desired state of applications is stored in a Git repository. Changes to applications are made through Git commits and pull requests, providing a reliable and auditable approach to managing configurations.

3. **Automated Synchronization**: ArgoCD continuously syncs the desired state from the Git repository to the target Kubernetes clusters, ensuring that applications are always running in the specified state.

4. **Multi-Cluster Support**: It can manage applications across multiple Kubernetes clusters, making it suitable for complex multi-cluster or multi-environment deployments.

5. **Rollback and History**: ArgoCD keeps a history of application changes and allows you to easily rollback to previous versions if needed.

6. **RBAC Integration**: It integrates with Kubernetes Role-Based Access Control (RBAC) to provide fine-grained access control and permissions management.

7. **Web UI and CLI**: ArgoCD provides both a web-based user interface and a command-line interface (CLI) for managing applications and clusters.

8. **Extensibility**: It can be extended with custom plugins and hooks to accommodate complex deployment scenarios.

ArgoCD is a popular choice for organizations looking to adopt GitOps practices in their Kubernetes deployments. It helps streamline application deployment and management processes, ensures consistency across environments, and provides transparency and traceability in the deployment pipeline.



**Steps**

1- Edit install-argocd.yaml and change image registry.

Example:
![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/53da33dd-6c58-4edd-8855-65dac0b9b687)

2- Deploy install-argocd.yaml:
```
bash ./install.sh
```
4- Check pods:

![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/550b6731-c4c7-4eac-b7bd-c55b10560f7a)

5- Create Nginx Ingress with self sign certificate.
```
openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 #Set your own info for example: country name,city name and ...
```
```
export TLSCERT=$(cat tls.crt|base64 #Change tls.crt content to base64)
export TLSKEY=$cat tls.key|base64 #Change tls.key content to base64)
```
```
# Create secret manifest file for storing tls data

cat <<EOF> argocd-self-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: self-signed-tls-secret
  namespace: argocd
data:
  tls.crt: $TLSCERT
  tls.key: $TLSKEY
EOF

```
```
kubectl apply -f argocd-self-secret.yaml #Deploy secret
```
```
# Create Nginx Ingress  manifest file

cat <<EOF> ingress-argocd.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
spec:
  tls:
  - hosts:
      - argocd.local
    secretName: argocd-tls-secret
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF

```
*Note:* You can change "argocd.local" hostname with own hostname (DNS name or hosts file in OS).

6- Deploy  Nginx Ingress masnifest file:
```
kubectl apply -f ingress-argocd.yaml
```
7- Login to Argocd UI:

![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/8e85f1fd-620a-4899-ac86-b84d4262cc53)

*Note:* Argocd default password stored on secret "argocd-initial-admin-secret".

![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/5a0f32a6-f163-4887-ae53-a77cd436d97f)

*Note:* Default Argocd password store as base64 on "argocd-initial-admin-secret".you can use this command for decode password:
```
kubectl get secrets -n argocd argocd-initial-admin-secret -o yaml|grep password|awk {'print $2'}|base64 -d
```

![image](https://github.com/IMAN-NAMJOOYAN/Installing_Argocd_on_kubernetes/assets/16554389/2ac53094-cf91-4240-acf4-61cddbd725ba)






