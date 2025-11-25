#!/bin/bash

# Script to reset onboarding flag for testing
# This will clear app data and make the app show onboarding pages again

echo "🔄 Resetting Smart Expense Tracker onboarding..."
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found. Please ensure Android SDK platform-tools are in your PATH."
    exit 1
fi

# Get package name
PACKAGE="com.example.smart_expense_tracker"

# Check if app is installed
if adb shell pm list packages | grep -q "$PACKAGE"; then
    echo "📱 Found app: $PACKAGE"
    echo "🗑️  Clearing app data..."
    adb shell pm clear $PACKAGE
    echo "✅ App data cleared successfully!"
    echo ""
    echo "🎉 You can now run the app to see onboarding pages again."
    echo "   Run: flutter run"
else
    echo "⚠️  App not installed on device/emulator"
    echo "   Install it first with: flutter run"
fi
