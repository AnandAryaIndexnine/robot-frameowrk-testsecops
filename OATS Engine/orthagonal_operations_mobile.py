import json
from itertools import product

def generate_mobile_testing_combinations(factors, levels):
    """Generate test combinations for mobile testing."""
    combinations = []
    
    # Get all possible combinations using itertools.product
    keys = factors
    values = [levels[factor] for factor in factors]
    
    for combination in product(*values):
        combo_dict = dict(zip(keys, combination))
        # Only add valid combinations based on platform
        if is_valid_combination(combo_dict):
            combinations.append(combo_dict)
    
    return combinations

def is_valid_combination(combination):
    """
    Validate if the combination is valid based on platform-specific rules.
    For example, certain devices are only available for specific platforms.
    """
    platform = combination.get('platform', '').lower()
    device = combination.get('device', '').lower()
    
    # iOS devices should only be paired with iOS platform
    ios_devices = ['iphone 14', 'iphone 13', 'ipad pro']
    android_devices = ['pixel 7', 'samsung s23', 'oneplus 11']
    
    if platform == 'ios' and device not in ios_devices:
        return False
    if platform == 'android' and device not in android_devices:
        return False
    
    return True

def write_combinations_to_json(combinations, output_file):
    """Write the generated combinations to a JSON file."""
    try:
        with open(output_file, 'w') as file:
            json.dump(combinations, file, indent=4)
        print(f"Successfully wrote combinations to '{output_file}'")
    except Exception as e:
        print(f"Error writing to JSON file: {e}")

def generate_appium_capabilities(combination):
    """
    Generate Appium capabilities based on the combination.
    This can be used later for actual test execution.
    """
    platform = combination['platform'].lower()
    device = combination['device'].lower()
    os_version = combination['os_version']
    
    capabilities = {
        "platformName": platform.capitalize(),
        "deviceName": device,
        "platformVersion": os_version,
        "automationName": "XCUITest" if platform == "ios" else "UiAutomator2",
        "noReset": False,
    }
    
    # Add platform-specific capabilities
    if platform == "android":
        capabilities.update({
            "appPackage": "your.app.package",
            "appActivity": "your.app.activity",
        })
    elif platform == "ios":
        capabilities.update({
            "bundleId": "your.app.bundleid",
            "xcodeOrgId": "your-team-id",
            "xcodeSigningId": "iPhone Developer",
        })
    
    return capabilities

if __name__ == "__main__":
    # Define test factors and their levels
    factors = ["platform", "device", "os_version", "app_type"]
    levels = {
        "platform": ["Android", "iOS"],
        "device": [
            "Pixel 7", "Samsung S23", "OnePlus 11",
            "iPhone 14", "iPhone 13", "iPad Pro"
        ],
        "os_version": [
            "13.0", "12.0", "11.0",
            "16.0", "15.0", "14.0"
        ],
        "app_type": ["Native", "Hybrid"]
    }
    
    # Generate test combinations
    test_combinations = generate_mobile_testing_combinations(factors, levels)
    
    # Write combinations to JSON file
    write_combinations_to_json(test_combinations, "mobile_test_combinations.json")
    
    # Generate and write Appium capabilities for each combination
    appium_configs = []
    for combination in test_combinations:
        capabilities = generate_appium_capabilities(combination)
        appium_configs.append({
            "test_combination": combination,
            "appium_capabilities": capabilities
        })
    
    write_combinations_to_json(appium_configs, "appium_configurations.json")
    
    # Print summary
    print(f"\nGenerated {len(test_combinations)} valid test combinations")
    print(f"Android combinations: {sum(1 for c in test_combinations if c['platform'].lower() == 'android')}")
    print(f"iOS combinations: {sum(1 for c in test_combinations if c['platform'].lower() == 'ios')}")