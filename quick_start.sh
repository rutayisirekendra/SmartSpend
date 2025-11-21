#!/bin/bash

# Quick Start - Fix and Run
# This script applies all fixes and runs the app

echo "🚀 Smart Expense Tracker - Quick Start"
echo "======================================"
echo ""

# Step 1: Apply network fixes if emulator is running
if adb devices | grep -q "emulator"; then
    echo "📡 Applying network fixes..."
    adb shell settings put global default_dns_server 8.8.8.8
    adb shell setprop net.dns1 8.8.8.8
    adb shell setprop net.dns2 8.8.4.4
    adb shell pm clear com.example.smart_expense_tracker 2>/dev/null
    echo "✅ Network configured"
    echo ""
fi

# Step 2: Clean and rebuild
echo "🔨 Rebuilding app..."
flutter clean
flutter pub get

# Step 3: Run
echo ""
echo "🎯 Starting app..."
echo ""
flutter run

