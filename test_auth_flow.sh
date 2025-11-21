#!/bin/zsh

# Quick Test Script for Authentication Flow
# Run this to test all authentication features

echo "🚀 Smart Expense Tracker - Authentication Test"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${BLUE}📋 Test Checklist:${NC}"
echo ""

echo "${YELLOW}1. First Time User Experience:${NC}"
echo "   □ Uninstall app to reset"
echo "   □ Launch app"
echo "   □ See splash screen for 2 seconds"
echo "   □ See onboarding (3 pages)"
echo "   □ Swipe through pages"
echo "   □ Click 'Get Started' on last page"
echo "   □ Land on signup/login screen"
echo ""

echo "${YELLOW}2. Navigation Test:${NC}"
echo "   □ On Signup screen, click 'Already have an account? Login'"
echo "   □ Should switch to Login screen"
echo "   □ On Login screen, click 'Don't have an account? Sign Up'"
echo "   □ Should switch to Signup screen"
echo "   □ Toggle switch also works"
echo ""

echo "${YELLOW}3. Signup Flow:${NC}"
echo "   □ Fill in:"
echo "      - Name: Test User"
echo "      - Email: test@example.com"
echo "      - Password: Test123!"
echo "      - Confirm Password: Test123!"
echo "   □ Check Terms & Conditions"
echo "   □ Click SIGN UP"
echo "   □ See success message"
echo "   □ Automatically logged in"
echo "   □ Navigate to main screen"
echo ""

echo "${YELLOW}4. Login Flow:${NC}"
echo "   □ Sign out from profile"
echo "   □ Enter email: test@example.com"
echo "   □ Enter password: Test123!"
echo "   □ Click LOGIN"
echo "   □ See welcome message"
echo "   □ Navigate to main screen"
echo ""

echo "${YELLOW}5. Subsequent Launch:${NC}"
echo "   □ Close app completely"
echo "   □ Relaunch app"
echo "   □ See splash screen (2 sec)"
echo "   □ Skip onboarding (already seen)"
echo "   □ If logged in → Go to main screen"
echo "   □ If not logged in → Go to login screen"
echo ""

echo "=============================================="
echo ""
echo "${GREEN}Would you like to:${NC}"
echo "1) ${BLUE}Run app now${NC}"
echo "2) ${BLUE}Reset onboarding (uninstall & run)${NC}"
echo "3) ${BLUE}Just run flutter analyze${NC}"
echo ""

read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "${GREEN}✅ Running app...${NC}"
        flutter run
        ;;
    2)
        echo ""
        echo "${GREEN}✅ Uninstalling app to reset onboarding...${NC}"
        adb uninstall com.example.smart_expense_tracker
        echo "${GREEN}✅ Running app...${NC}"
        flutter run
        ;;
    3)
        echo ""
        echo "${GREEN}✅ Running flutter analyze...${NC}"
        flutter analyze
        ;;
    *)
        echo ""
        echo "${YELLOW}Invalid choice. Run manually:${NC}"
        echo "  flutter run"
        ;;
esac
