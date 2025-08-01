#!/bin/bash

# Valet Zsh Plugin Compatibility Test Script
# Tests the plugin across different environments and plugin managers

set -e

echo "🧪 Testing Valet Zsh Plugin Compatibility"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test results
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check if plugin file exists
echo -e "\n${BLUE}Test 1: Plugin file existence${NC}"
if [ -f "valet.plugin.zsh" ]; then
    test_result 0 "Plugin file exists"
else
    test_result 1 "Plugin file missing"
    exit 1
fi

# Test 2: Check syntax
echo -e "\n${BLUE}Test 2: Shell syntax validation${NC}"
zsh -n valet.plugin.zsh 2>/dev/null
test_result $? "Zsh syntax validation"

# Test 3: Basic loading test
echo -e "\n${BLUE}Test 3: Basic plugin loading${NC}"
zsh -c "source valet.plugin.zsh 2>/dev/null && echo 'Plugin loaded successfully'" >/dev/null 2>&1
test_result $? "Plugin loads without errors"

# Test 4: Function availability
echo -e "\n${BLUE}Test 4: Helper functions availability${NC}"
functions_to_test=(
    "valet-status"
    "valet-open"
    "valet-link-here"
    "valet-secure-here"
    "valet-logs"
)

for func in "${functions_to_test[@]}"; do
    zsh -c "source valet.plugin.zsh && type $func >/dev/null 2>&1"
    test_result $? "Function '$func' is defined"
done

# Test 5: Aliases availability
echo -e "\n${BLUE}Test 5: Aliases availability${NC}"
aliases_to_test=(
    "vs"
    "vo"
    "vlh"
    "vsh"
    "vl"
    "vp"
    "vlog"
)

for alias_name in "${aliases_to_test[@]}"; do
    zsh -c "source valet.plugin.zsh && alias $alias_name >/dev/null 2>&1"
    test_result $? "Alias '$alias_name' is defined"
done

# Test 6: Completion function
echo -e "\n${BLUE}Test 6: Completion function${NC}"
zsh -c "source valet.plugin.zsh && type _valet >/dev/null 2>&1"
test_result $? "Completion function '_valet' is defined"

# Test 7: Plugin manager detection
echo -e "\n${BLUE}Test 7: Plugin manager detection${NC}"
zsh -c "source valet.plugin.zsh && echo \$VALET_PLUGIN_MANAGER" | grep -E "(oh-my-zsh|zinit|antigen|zplug|prezto|antibody|manual)" >/dev/null
test_result $? "Plugin manager detection works"

# Test 8: Environment variable handling
echo -e "\n${BLUE}Test 8: Environment variable handling${NC}"
VALET_PLUGIN_SILENT_LOAD=true zsh -c "source valet.plugin.zsh" 2>&1 | grep -v "Plugin loaded" >/dev/null
test_result $? "Silent loading works"

# Test 9: Error handling for missing valet
echo -e "\n${BLUE}Test 9: Error handling${NC}"
# Temporarily rename valet if it exists
if command -v valet >/dev/null 2>&1; then
    VALET_PATH=$(which valet)
    sudo mv "$VALET_PATH" "$VALET_PATH.backup" 2>/dev/null || echo "Cannot move valet binary for testing"
fi

# Test error handling
zsh -c "source valet.plugin.zsh && valet-status" 2>&1 | grep -q "not installed" 
test_result $? "Error handling for missing valet"

# Restore valet if we moved it
if [ -f "$VALET_PATH.backup" ]; then
    sudo mv "$VALET_PATH.backup" "$VALET_PATH" 2>/dev/null || echo "Cannot restore valet binary"
fi

# Test 10: Plugin manager specific loading
echo -e "\n${BLUE}Test 10: Plugin manager compatibility${NC}"

# Simulate Oh My Zsh environment
ZSH="/tmp/oh-my-zsh" zsh -c "source valet.plugin.zsh && echo \$VALET_PLUGIN_MANAGER" | grep -q "oh-my-zsh"
test_result $? "Oh My Zsh detection"

# Test with different plugin managers
test_plugin_manager() {
    local manager=$1
    local env_var=$2
    local env_value=$3
    
    eval "$env_var=\"$env_value\"" zsh -c "source valet.plugin.zsh && echo \$VALET_PLUGIN_MANAGER" | grep -q "$manager"
    test_result $? "$manager detection"
}

test_plugin_manager "zinit" "ZINIT" "1"
test_plugin_manager "antigen" "ADOTDIR" "/tmp/antigen"
test_plugin_manager "zplug" "ZPLUG_HOME" "/tmp/zplug"

# Final results
echo -e "\n${BLUE}Test Results Summary${NC}"
echo "===================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
echo -e "Success Rate: ${SUCCESS_RATE}%"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Plugin is ready for publication.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please fix the issues before publishing.${NC}"
    exit 1
fi