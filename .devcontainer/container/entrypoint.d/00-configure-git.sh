
GIT_VARS=(
    GIT_USERNAME
    GIT_EMAIL
    GIT_TOKEN
)

if check_required_vars "GIT" "${GIT_VARS[@]}"; then
  log_info "[GIT] Configuring username and email..."
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global credential.helper store
  echo "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com" > ~/.git-credentials
else
  log_warning "[GIT] skipped configuration."
fi
