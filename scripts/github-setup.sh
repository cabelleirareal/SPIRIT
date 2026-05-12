#!/bin/bash

# ============================================
# SPIRIT - Automated GitHub Setup
# ============================================

set -e

echo "============================================"
echo "🔮 SPIRIT - GitHub Repository Setup"
echo "============================================"
echo ""

# Get GitHub credentials
read -p "GitHub Username: " GITHUB_USER
read -sp "GitHub Personal Access Token: " GITHUB_TOKEN
echo ""
echo ""

if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Username and token are required!"
    exit 1
fi

# Repository details
REPO_NAME="SPIRIT"
REPO_DESC="Strategic Predictive Intelligence & Research Intelligence Technology - AI-powered decision platform"

echo "Creating repository: $GITHUB_USER/$REPO_NAME"
echo ""

# Create repository via GitHub API
echo "📦 Creating GitHub repository..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"$REPO_DESC\",
    \"homepage\": \"https://spirit.ai\",
    \"private\": false,
    \"has_issues\": true,
    \"has_projects\": true,
    \"has_wiki\": true,
    \"auto_init\": false
  }")

# Check if creation was successful
if echo "$RESPONSE" | grep -q "\"name\": \"$REPO_NAME\""; then
    echo "✅ Repository created successfully!"
else
    echo "❌ Failed to create repository"
    echo "Response: $RESPONSE"
    exit 1
fi

echo ""

# Configure git remote
echo "🔗 Configuring git remote..."
cd /home/claude/spirit

# Remove existing remote if exists
git remote remove origin 2>/dev/null || true

# Add new remote with token
git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git

echo "✅ Remote configured"
echo ""

# Push to GitHub
echo "⬆️  Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "============================================"
echo "✅ SUCCESS!"
echo "============================================"
echo ""
echo "Repository created and code pushed!"
echo ""
echo "🔗 View at: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "Next steps:"
echo "  1. Visit your repo on GitHub"
echo "  2. Add topics/tags (ai, decision-intelligence, docker)"
echo "  3. Create first release (v1.0.0)"
echo "  4. Share on social media"
echo ""
echo "To run locally:"
echo "  cd /home/claude/spirit"
echo "  cp .env.example .env"
echo "  # Edit .env with API keys"
echo "  ./scripts/setup.sh"
echo ""
