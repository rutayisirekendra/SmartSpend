#!/bin/bash

echo "🔧 Smart Expense Tracker - Network Fix Script"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}❌ ADB not found. Please install Android SDK Platform Tools.${NC}"
    exit 1
fi

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo -e "${YELLOW}⚠️  No emulator detected.${NC}"
    echo "Please start your Android emulator and run this script again."
    exit 1
fi

echo -e "${GREEN}✅ Emulator detected${NC}"
echo ""

# Fix 1: Set Google DNS servers
echo "🔧 Fix 1: Configuring Google DNS Servers..."
adb shell settings put global default_dns_server 8.8.8.8
adb shell setprop net.dns1 8.8.8.8
adb shell setprop net.dns2 8.8.4.4
echo -e "${GREEN}   ✅ DNS servers configured${NC}"
echo ""

# Fix 2: Clear app data
echo "🔧 Fix 2: Clearing app data..."
adb shell pm clear com.example.smart_expense_tracker 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ App data cleared${NC}"
else
    echo -e "${YELLOW}   ⚠️  App not installed yet (this is OK)${NC}"
fi
echo ""

# Fix 3: Sync time
echo "🔧 Fix 3: Syncing device time..."
adb shell "su 0 date $(date +%m%d%H%M%Y.%S)" 2>/dev/null || \
adb shell "date $(date +%m%d%H%M%Y.%S)" 2>/dev/null || \
echo -e "${YELLOW}   ⚠️  Could not sync time (may require root)${NC}"
echo ""

# Fix 4: Test connectivity
echo "🔧 Fix 4: Testing connectivity..."
if adb shell ping -c 2 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}   ✅ Internet connection working${NC}"
else
    echo -e "${RED}   ❌ No internet connection${NC}"
    echo -e "${YELLOW}   💡 Try: Emulator Settings → Network → Reset${NC}"
fi

if adb shell ping -c 2 google.com &> /dev/null; then
    echo -e "${GREEN}   ✅ DNS resolution working${NC}"
else
    echo -e "${YELLOW}   ⚠️  DNS resolution issues detected${NC}"
fi

if adb shell ping -c 2 firebaseauth.googleapis.com &> /dev/null; then
    echo -e "${GREEN}   ✅ Can reach Firebase servers${NC}"
else
    echo -e "${YELLOW}   ⚠️  Cannot reach Firebase (this might be normal)${NC}"
fi
echo ""

# Fix 5: Rebuild and run app
echo "🔧 Fix 5: Rebuilding app..."
echo "Running: flutter clean && flutter pub get"
flutter clean
flutter pub get

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Network fixes applied!${NC}"
echo ""
echo "Next steps:"
echo "1. Run: flutter run"
echo "2. Try to sign up or login"
echo "3. If still failing, check Firebase Console:"
echo "   https://console.firebase.google.com"
echo "   → Authentication → Sign-in method"
echo "   → Ensure Email/Password is ENABLED"
echo ""
echo "Alternative: If emulator still has issues,"
echo "test on a physical device:"
echo "   flutter run -d <your-device>"
echo "=============================================="
