#!/bin/zsh

# Firebase Authentication Test Script
# Run this after completing Firebase Console setup

echo "🚀 Firebase Authentication Test"
echo "================================"
echo ""

echo "Step 1: Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi
echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

echo "Step 2: Checking for emulator/device..."
flutter devices
echo ""

echo "Step 3: Building and running app..."
echo "⏳ This may take 2-3 minutes..."
echo ""

flutter run --debug

echo ""
echo "================================"
echo "📝 Testing Instructions:"
echo ""
echo "1. Wait for app to launch"
echo "2. Look for this in console:"
echo "   ✅ 'DEBUG MODE: Skipping App Check'"
echo ""
echo "3. In the app:"
echo "   - Click 'Sign Up'"
echo "   - Enter: Name, Email, Password"
echo "   - Click 'Create Account'"
echo ""
echo "4. Expected result:"
echo "   ✅ User created"
echo "   ✅ Auto logged in"
echo "   ✅ See dashboard"
echo ""
echo "5. Test login:"
echo "   - Sign out from profile"
echo "   - Use same credentials to log in"
echo ""
echo "================================"
