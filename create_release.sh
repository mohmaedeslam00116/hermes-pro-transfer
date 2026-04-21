#!/bin/bash

# Hermes Release Script
# Usage: ./create_release.sh v1.0.0-beta.1

TAG=$1

if [ -z "$TAG" ]; then
    echo "Usage: ./create_release.sh <tag-version>"
    echo "Example: ./create_release.sh v1.0.0-beta.1"
    exit 1
fi

echo "Creating release for tag: $TAG"
echo "This will push the tag to GitHub and trigger the CI/CD pipeline."
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Add all changes
    git add -A
    
    # Create commit
    git commit -m "Release $TAG"
    
    # Create and push tag
    git tag -a $TAG -m "Release $TAG"
    git push origin main
    git push origin $TAG
    
    echo ""
    echo "✅ Release $TAG created and pushed!"
    echo "📦 CI/CD will build and create the release automatically."
    echo "🔗 Check: https://github.com/mohmaedeslam00116/hermes-pro-transfer/actions"
else
    echo "Release cancelled."
fi
