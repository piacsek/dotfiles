#!/bin/bash

SESSION_NAME="workspace"
PROJECT_DIR="$HOME/projects/wonderschool/ws-common/apps/nova"

# Check if session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
  # Create new session with first window
  tmux new-session -d -s $SESSION_NAME -c $PROJECT_DIR -n editor
  tmux send-keys -t $SESSION_NAME:editor "nvim" C-m

  # Create second window for server
  tmux new-window -t $SESSION_NAME -n server -c $PROJECT_DIR
  tmux send-keys -t $SESSION_NAME:server "iex -S mix phx.server" C-m

  # Select the first window
  tmux select-window -t $SESSION_NAME:editor
fi

# Attach to session
tmux attach-session -t $SESSION_NAME
