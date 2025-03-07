import json
import os
import subprocess
import oapackage
from typing import Dict, List, Optional
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'test_generation_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TestCombinationGenerator:
    def __init__(self, factors: List[str], levels: Dict[str, List[str]]):
        """
        Initialize the test combination generator.
        
        Args:
            factors: List of test factors
            levels: Dictionary of levels for each factor
        """
        self.factors = factors
        self.levels = levels
        self.validate_inputs()

    def validate_inputs(self):
        """Validate the input factors and levels."""
        if len(self.factors) != len(self.levels):
            raise ValueError("Number of factors must match the number of level dictionaries.")
        
        for factor in self.factors:
            if factor not in self.levels:
                raise ValueError(f"Factor '{factor}' not found in levels dictionary.")
            if not self.levels[factor]:
                raise ValueError(f"No levels defined for factor '{factor}'.")

    def generate_combinations(self, runs: Optional[int] = None) -> List[Dict[str, str]]:
        """
        Generate test combinations using orthogonal array testing strategy.
        
        Args:
            runs: Number of test runs (optional)
            
        Returns:
            List of test combinations
        """
        if runs is None:
            runs = self._find_suitable_runs()

        try:
            array_class = oapackage.arraydata_t(
                len(self.levels[self.factors[0]]), 
                runs, 
                len(self.factors), 
                len(self.factors)
            )
            array_link = array_class.create_root()
            generated_array = array_link.getarray()

            combinations = []
            for i in range(runs):
                combination = {}
                for j, factor in enumerate(self.factors):
                    combination[factor] = self.levels[factor][
                        generated_array[i][j] % len(self.levels[factor])
                    ]
                combinations.append(combination)

            return combinations

        except Exception as e:
            logger.error(f"Error generating combinations: {str(e)}")
            raise

    def _find_suitable_runs(self) -> int:
        """
        Find suitable number of runs based on factors and levels.
        
        Returns:
            Number of test runs
        """
        # Calculate minimum runs needed based on factors and levels
        max_levels = max(len(levels) for levels in self.levels.values())
        min_runs = max(len(self.factors) * 2, max_levels)
        return min_runs

class TestConfigurationManager:
    def __init__(self, output_dir: str = "test_configurations"):
        """
        Initialize the test configuration manager.
        
        Args:
            output_dir: Directory to store output files
        """
        self.output_dir = output_dir
        self._ensure_output_directory()

    def _ensure_output_directory(self):
        """Ensure the output directory exists."""
        os.makedirs(self.output_dir, exist_ok=True)

    def write_combinations(self, combinations: List[Dict[str, str]], filename: str):
        """
        Write test combinations to a JSON file.
        
        Args:
            combinations: List of test combinations
            filename: Output filename
        """
        output_path = os.path.join(self.output_dir, filename)
        try:
            with open(output_path, 'w') as file:
                json.dump(
                    {
                        "generated_at": datetime.now().isoformat(),
                        "total_combinations": len(combinations),
                        "combinations": combinations
                    }, 
                    file, 
                    indent=4
                )
            logger.info(f"Successfully wrote combinations to '{output_path}'")
        except Exception as e:
            logger.error(f"Error writing combinations to file: {str(e)}")
            raise

    def generate_test_config(self, combination: Dict[str, str]) -> Dict[str, any]:
        """
        Generate test configuration for a combination.
        
        Args:
            combination: Test combination
            
        Returns:
            Test configuration dictionary
        """
        config = {
            "test_environment": combination.copy(),
            "execution_settings": {
                "timeout": 300,
                "retry_attempts": 2,
                "screenshot_on_failure": True
            }
        }

        # Add browser-specific settings
        if "browser" in combination:
            config["browser_settings"] = self._get_browser_settings(combination["browser"])

        # Add OS-specific settings
        if "operating_system" in combination:
            config["os_settings"] = self._get_os_settings(combination["operating_system"])

        return config

    def _get_browser_settings(self, browser: str) -> Dict[str, any]:
        """Get browser-specific settings."""
        settings = {
            "chrome": {
                "arguments": ["--no-sandbox", "--disable-gpu", "--headless"],
                "preferences": {"download.default_directory": "/downloads"}
            },
            "firefox": {
                "arguments": ["-headless"],
                "preferences": {"browser.download.folderList": 2}
            },
            "edge": {
                "arguments": ["--headless"],
                "preferences": {}
            }
        }
        return settings.get(browser.lower(), {})

    def _get_os_settings(self, operating_system: str) -> Dict[str, any]:
        """Get OS-specific settings."""
        settings = {
            "windows": {
                "screen_resolution": "1920x1080",
                "system_type": "Windows"
            },
            "ubuntu 20.04": {
                "screen_resolution": "1920x1080",
                "system_type": "Linux"
            },
            "ubuntu 22.04": {
                "screen_resolution": "1920x1080",
                "system_type": "Linux"
            }
        }
        return settings.get(operating_system.lower(), {})

def main():
    try:
        # Define test factors and levels
        factors = ["operating_system", "browser"]
        levels = {
            "operating_system": ["Windows", "ubuntu 22.04", "ubuntu 20.04"],
            "browser": ["chrome", "firefox", "edge"]
        }

        # Generate test combinations
        generator = TestCombinationGenerator(factors, levels)
        test_combinations = generator.generate_combinations()

        # Initialize configuration manager
        config_manager = TestConfigurationManager()

        # Write basic combinations
        config_manager.write_combinations(
            test_combinations,
            "test_combinations.json"
        )

        # Generate and write detailed test configurations
        detailed_configs = [
            config_manager.generate_test_config(combo)
            for combo in test_combinations
        ]
        config_manager.write_combinations(
            detailed_configs,
            "test_configurations.json"
        )

        logger.info(f"Successfully generated {len(test_combinations)} test combinations")

    except Exception as e:
        logger.error(f"Error in main execution: {str(e)}")
        raise

if __name__ == "__main__":
    main()