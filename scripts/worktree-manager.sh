#!/usr/bin/env bash
# Worktree 管理脚本 — 支持并行隔离开发
# Usage: ./scripts/worktree-manager.sh <command> [args]
#
# Commands:
#   create <issue-number> <branch-suffix>  创建新 worktree 和分支
#   list                                   列出所有 worktree
#   push <issue-number>                    推送指定 worktree 的分支
#   cleanup <issue-number>                 清理并删除 worktree
#   cleanup-merged                         删除已合并的 worktree

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"
WORKTREE_DIR="$REPO_ROOT"

cmd_help() {
  echo "Worktree Manager — 并行开发隔离工具"
  echo ""
  echo "Usage:"
  echo "  $(basename "$0") create <issue-number> <branch-suffix>   创建 worktree"
  echo "  $(basename "$0") list                                      列出 worktree"
  echo "  $(basename "$0") push <issue-number>                       推送分支"
  echo "  $(basename "$0") cleanup <issue-number>                    删除 worktree"
  echo "  $(basename "$0") cleanup-merged                            清理已合并的 worktree"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") create 123 feature/auth"
  echo "  $(basename "$0") cleanup 123"
}

cmd_create() {
  local issue_number="${1:-}"
  local branch_suffix="${2:-}"

  if [ -z "$issue_number" ] || [ -z "$branch_suffix" ]; then
    echo "❌ Usage: $(basename "$0") create <issue-number> <branch-suffix>"
    exit 1
  fi

  local branch_name="issue-${issue_number}-${branch_suffix}"
  local target_path="${REPO_ROOT%/*}/${REPO_NAME}-issue-${issue_number}"

  if [ -d "$target_path" ]; then
    echo "⚠️  Worktree already exists at $target_path"
    echo "   Use: cd \"$target_path\""
    exit 0
  fi

  echo "🌲 Creating worktree..."
  echo "   Branch: $branch_name"
  echo "   Path:   $target_path"

  git worktree add "$target_path" -b "$branch_name"

  echo ""
  echo "✅ Worktree created. Next steps:"
  echo "   cd \"$target_path\""
  echo "   # Start your work here"
  echo "   # When done: $(basename "$0") push $issue_number"
}

cmd_list() {
  echo "📋 Worktree list:"
  git worktree list --porcelain | awk '/worktree / {print $2}' | while read -r path; do
    local branch
    branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
    echo "   $path ($branch)"
  done
}

cmd_push() {
  local issue_number="${1:-}"
  if [ -z "$issue_number" ]; then
    echo "❌ Usage: $(basename "$0") push <issue-number>"
    exit 1
  fi

  local target_path="${REPO_ROOT%/*}/${REPO_NAME}-issue-${issue_number}"
  if [ ! -d "$target_path" ]; then
    echo "❌ Worktree not found: $target_path"
    exit 1
  fi

  local branch_name
  branch_name=$(git -C "$target_path" rev-parse --abbrev-ref HEAD)

  echo "🚀 Pushing branch $branch_name..."
  git -C "$target_path" push -u origin "$branch_name"
  echo "✅ Pushed. Create PR with: gh pr create --base main --head $branch_name"
}

cmd_cleanup() {
  local issue_number="${1:-}"
  if [ -z "$issue_number" ]; then
    echo "❌ Usage: $(basename "$0") cleanup <issue-number>"
    exit 1
  fi

  local target_path="${REPO_ROOT%/*}/${REPO_NAME}-issue-${issue_number}"
  if [ ! -d "$target_path" ]; then
    echo "❌ Worktree not found: $target_path"
    exit 1
  fi

  local branch_name
  branch_name=$(git -C "$target_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

  # Check for uncommitted changes
  if [ -n "$(git -C "$target_path" status --porcelain 2>/dev/null)" ]; then
    echo "⚠️  Uncommitted changes detected in $target_path"
    echo "   Commit or stash before cleanup."
    exit 1
  fi

  echo "🧹 Removing worktree: $target_path"
  git worktree remove "$target_path" 2>/dev/null || rm -rf "$target_path"

  if [ -n "$branch_name" ] && [ "$branch_name" != "main" ] && [ "$branch_name" != "master" ]; then
    read -r -p "🗑  Also delete branch '$branch_name'? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      git branch -D "$branch_name" 2>/dev/null || echo "   Branch already deleted or remote-only"
    fi
  fi

  echo "✅ Cleanup complete"
}

cmd_cleanup_merged() {
  echo "🔍 Scanning for merged branches with worktrees..."
  git worktree list --porcelain | awk '/worktree / {print $2}' | while read -r path; do
    local branch
    branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || continue)

    if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
      continue
    fi

    if git branch --merged main | grep -q "$branch" 2>/dev/null; then
      echo "   🗑  $branch (merged) -> $path"
      git worktree remove "$path" 2>/dev/null || rm -rf "$path"
      git branch -D "$branch" 2>/dev/null || true
    fi
  done
  echo "✅ Cleanup complete"
}

# Main
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
  create) cmd_create "$@" ;;
  list) cmd_list "$@" ;;
  push) cmd_push "$@" ;;
  cleanup) cmd_cleanup "$@" ;;
  cleanup-merged) cmd_cleanup_merged "$@" ;;
  help|--help|-h) cmd_help ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    cmd_help
    exit 1
    ;;
esac
