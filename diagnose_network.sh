#!/bin/bash

echo "🔍 Smart Expense Tracker - Network Diagnostics"
echo "=============================================="
echo ""

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android SDK Platform Tools."
    exit 1
fi

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo "❌ No emulator detected. Please start your Android emulator first."
    exit 1
fi

echo "✅ Emulator detected"
echo ""

# Test 1: Internet connectivity
echo "📡 Test 1: Checking Internet Connectivity..."
if adb shell ping -c 3 8.8.8.8 &> /dev/null; then
    echo "   ✅ Internet connection OK"
else
    echo "   ❌ No internet connection"
    echo "   💡 Try restarting the emulator"
fi
echo ""

# Test 2: DNS resolution
echo "🌐 Test 2: Checking DNS Resolution..."
if adb shell ping -c 3 google.com &> /dev/null; then
    echo "   ✅ DNS resolution working"
else
    echo "   ❌ DNS resolution failed"
    echo "   💡 Fix: adb shell settings put global default_dns_server 8.8.8.8"
fi
echo ""

# Test 3: Firebase connectivity
echo "🔥 Test 3: Checking Firebase Connectivity..."
if adb shell ping -c 3 firebaseauth.googleapis.com &> /dev/null; then
    echo "   ✅ Can reach Firebase Auth servers"
else
    echo "   ⚠️  Cannot reach Firebase Auth servers"
    echo "   💡 This might be a DNS issue"
fi
echo ""

# Test 4: Check DNS servers
echo "🔧 Test 4: Current DNS Configuration..."
DNS1=$(adb shell getprop net.dns1 2>/dev/null)
DNS2=$(adb shell getprop net.dns2 2>/dev/null)
echo "   Primary DNS: ${DNS1:-Not set}"
echo "   Secondary DNS: ${DNS2:-Not set}"
echo ""

# Test 5: Check date/time
echo "⏰ Test 5: Checking System Time..."
DEVICE_TIME=$(adb shell date)
echo "   Device time: $DEVICE_TIME"
echo "   💡 Incorrect time can cause SSL/TLS errors"
echo ""

# Test 6: Check app installation
echo "📱 Test 6: Checking App Installation..."
if adb shell pm list packages | grep -q "com.example.smart_expense_tracker"; then
    echo "   ✅ App is installed"
else
    echo "   ⚠️  App not found"
    echo "   💡 Run: flutter run"
fi
echo ""

# Recommendations
echo "=============================================="
echo "📋 Recommendations:"
echo ""

if ! adb shell ping -c 1 8.8.8.8 &> /dev/null; then
    echo "🔴 CRITICAL: Fix internet connection first"
    echo "   1. Restart emulator: adb emu kill"
    echo "   2. Start with DNS: emulator -avd YOUR_AVD_NAME -dns-server 8.8.8.8"
    echo ""
fi

if ! adb shell ping -c 1 google.com &> /dev/null; then
    echo "🟡 WARNING: DNS not working"
    echo "   Run: adb shell settings put global default_dns_server 8.8.8.8"
    echo ""
fi

echo "🔄 Quick Fix Commands:"
echo "   # Set Google DNS"
echo "   adb shell settings put global default_dns_server 8.8.8.8"
echo ""
echo "   # Clear app data"
echo "   adb shell pm clear com.example.smart_expense_tracker"
echo ""
echo "   # Restart and run"
echo "   flutter clean && flutter pub get && flutter run"
echo ""
echo "=============================================="
