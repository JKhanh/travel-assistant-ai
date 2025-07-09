#!/bin/bash

# CI Validation Script for Travel Assistant AI
# This script validates that all CI pipeline components work locally

set -e

echo "🚀 Starting CI validation..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter is available"

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Check formatting
echo "🎨 Checking code formatting..."
dart format --output=none --set-exit-if-changed .

# Run static analysis
echo "🔍 Running static analysis..."
flutter analyze

# Run tests with coverage
echo "🧪 Running tests with coverage..."
flutter test --coverage

# Check if coverage directory exists
if [ -d "coverage" ]; then
    echo "✅ Coverage report generated"
else
    echo "⚠️  No coverage directory found"
fi

# Validate pubspec.yaml
echo "📋 Validating pubspec.yaml..."
flutter pub deps

# Check for security issues using OSV Scanner
echo "🔒 Running OSV Security Scan..."
if command -v osv-scanner &> /dev/null; then
    osv-scanner --recursive --skip-git ./
else
    echo "⚠️  OSV Scanner not installed. Install with: go install github.com/google/osv-scanner/cmd/osv-scanner@v1"
    echo "   Or download from: https://github.com/google/osv-scanner/releases"
    echo "   This scan will run in CI even without local installation"
fi

# Check for outdated dependencies
echo "📊 Checking for outdated dependencies..."
flutter pub outdated || echo "⚠️  Some dependencies are outdated"

# Test build commands (without actually building to save time)
echo "🔧 Validating build configurations..."

# Check Android configuration
if [ -d "android" ]; then
    echo "✅ Android configuration found"
else
    echo "❌ Android configuration missing"
    exit 1
fi

# Check iOS configuration
if [ -d "ios" ]; then
    echo "✅ iOS configuration found"
else
    echo "❌ iOS configuration missing"
    exit 1
fi

# Check web configuration
if [ -d "web" ]; then
    echo "✅ Web configuration found"
else
    echo "❌ Web configuration missing"
    exit 1
fi

# Validate GitHub Actions workflow
echo "🎯 Validating GitHub Actions workflow..."
if [ -f ".github/workflows/flutter-ci.yml" ]; then
    echo "✅ GitHub Actions workflow found"
else
    echo "❌ GitHub Actions workflow missing"
    exit 1
fi

# Check for Melos configuration
if [ -f "melos.yaml" ]; then
    echo "✅ Melos configuration found"
else
    echo "⚠️  Melos configuration not found (optional)"
fi

echo "🎉 All CI validation checks passed!"
echo "📝 Next steps:"
echo "   1. Push changes to GitHub"
echo "   2. Create a test PR to validate CI pipeline"
echo "   3. Set up branch protection rules (see .github/branch-protection-setup.md)"
echo "   4. Verify CI blocks merge on test failures"
