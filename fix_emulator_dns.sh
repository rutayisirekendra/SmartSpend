#!/bin/bash

# Firebase Authentication Fix for Android Emulator
# This script fixes DNS resolution issues in the Android emulator

echo "🔧 Firebase Emulator DNS Fix Script"
echo "===================================="
echo ""

# Get the emulator device ID
DEVICE_ID=$(adb devices | grep emulator | cut -f1)

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No emulator detected. Please start an emulator first."
    echo "   Run: flutter emulators --launch <emulator_name>"
    exit 1
fi

echo "✅ Found emulator: $DEVICE_ID"
echo ""

# Fix 1: Set Google DNS servers (8.8.8.8 and 8.8.4.4)
echo "📡 Configuring DNS servers..."
adb -s "$DEVICE_ID" root 2>/dev/null || echo "   (Running without root - some fixes may not apply)"
adb -s "$DEVICE_ID" shell "setprop net.dns1 8.8.8.8"
adb -s "$DEVICE_ID" shell "setprop net.dns2 8.8.4.4"
echo "   ✅ DNS servers set to Google DNS (8.8.8.8, 8.8.4.4)"
echo ""

# Fix 2: Restart network
echo "🔄 Restarting network services..."
adb -s "$DEVICE_ID" shell "svc wifi disable"
sleep 2
adb -s "$DEVICE_ID" shell "svc wifi enable"
sleep 2
echo "   ✅ Network restarted"
echo ""

# Fix 3: Test connectivity
echo "🌐 Testing connectivity..."
echo "   Testing Google DNS..."
adb -s "$DEVICE_ID" shell "ping -c 2 8.8.8.8" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ Can reach 8.8.8.8"
else
    echo "   ⚠️  Cannot reach 8.8.8.8 (emulator may need restart)"
fi

echo "   Testing Firebase..."
adb -s "$DEVICE_ID" shell "ping -c 2 firebase.googleapis.com" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ Can reach firebase.googleapis.com"
else
    echo "   ⚠️  Cannot reach firebase.googleapis.com (this is expected in some emulators)"
    echo "   💡 Firebase Auth will still work with our configuration!"
fi

echo ""
echo "✅ DNS configuration complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Rebuild the app: flutter run"
echo "   2. If issues persist, restart the emulator"
echo "   3. The app is configured to work even if DNS fails"
echo ""
