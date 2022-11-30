# shellcheck disable=SC2148

if command -v gcloud >/dev/null; then
  if ! gcloud components list --only-local-state 2>/dev/null | grep -q gke-gcloud-auth-plugin; then
    gcloud components install gke-gcloud-auth-plugin
  else
    gcloud components update
  fi
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
else
  echo "gcloud tool not installed"
fi
