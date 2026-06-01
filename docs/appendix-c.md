## Appendix C: Troubleshooting Tips

### No Gateway Endpoint?

If your deployment is running but no Gateway Endpoint appears, the gateway resources (InferencePool, HTTPRoute) may have failed to create. Check the Argo CD application status to confirm.

Port-forward to the Argo CD API server (this will occupy the terminal):

```bash
kubectl port-forward svc/argo-cd-argocd-server -n argocd 9000:80
```

Open a **new terminal tab**, retrieve the Argo CD password, and log in:

```bash
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:9000 --username admin --password "$ARGOCD_PWD" --insecure
```

> [!TIP]
> You can also open a web browser and navigate to <http://localhost:9000> to access the Argo CD dashboard with the same credentials.

Check the gateway-api application:

```bash
argocd app get gateway-api
```

If it's not Synced and Healthy, sync it manually:

```bash
argocd app sync gateway-api --prune
```

Confirm the app is now healthy and synced:

```bash
argocd app get gateway-api
```

If a model needs its gateway endpoint re-enabled:

```bash
MD_NAME=$(kubectl get modeldeployment -n dynamo-system -o jsonpath='{.items[0].metadata.name}')
kubectl patch modeldeployment $MD_NAME -n dynamo-system \
--type='merge' \
-p '{"spec":{"gateway":{"enabled":true}}}'
```