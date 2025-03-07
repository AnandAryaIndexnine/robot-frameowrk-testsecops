import json
from bs4 import BeautifulSoup
from rapidfuzz import fuzz
import os
from robot.libraries.BuiltIn import BuiltIn

def load_config():
    """Load configuration from config.json"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(current_dir)
    config_path = os.path.join(base_dir, 'Environment', 'config.json')
    
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found at {config_path}")

    with open(config_path, 'r') as config_file:
        config = json.load(config_file)
    
    return config, base_dir

# Load configuration
config, base_dir = load_config()

# Get paths from config
page_sources_dir = os.path.join(base_dir, config.get('page_sources_dir'))

def load_page_source(page_source_path):
    """
    Loads the page source from an HTML file.
    """
    with open(page_source_path, 'r', encoding='utf-8') as source_file:
        return source_file.read()

def generate_xpath(element):
    """
    Generates a basic XPath for an element by traversing its DOM hierarchy.
    Supports axes methods for more complex XPath generation.
    """
    parts = []
    while element:
        siblings = element.find_previous_siblings(element.name)
        index = len(siblings) + 1 if siblings else 1
        
        # Check for axes methods
        if element.name == 'input':
            # Example for child axis
            parts.insert(0, f"child::{element.name}[@id='{element.get('id')}']")
        else:
            parts.insert(0, f"{element.name}[{index}]")
        
        element = element.parent if element.parent.name != '[document]' else None
    return "//" + "/".join(parts)

def generate_best_candidates(locator, threshold=70):
    """
    Generates the best candidate locators from all page sources for a given failed locator.
    Returns the top 10 unique candidates based on similarity score across all pages.
    """
    all_candidates = []
    seen_xpaths = set()  # Track unique XPaths
    
    # Check if the locator is a valid XPath
    if locator.startswith("//"):
        # Handle complex XPath directly
        # You can implement a parsing logic here to analyze the XPath
        # For now, we will just log it
        print(f"Handling complex XPath: {locator}")
        # You can add logic to find similar elements based on this XPath

    # Check if directory exists
    if not os.path.exists(page_sources_dir):
        print(f"Warning: Page sources directory {page_sources_dir} not found")
        return [{"message": "No page sources found"}]
        
    # Iterate through all HTML files in the directory
    for filename in os.listdir(page_sources_dir):
        if not filename.endswith('.html'):
            continue
            
        try:
            # Load and parse each page source
            filepath = os.path.join(page_sources_dir, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                page_source = f.read()
                
            soup = BeautifulSoup(page_source, 'html.parser')
            
            # Find candidates in this page
            for element in soup.find_all():
                # Generate XPath first
                xpath = (
                    f"//{element.name}[@id='{element.get('id')}']"
                    if element.get("id") else generate_xpath(element)
                )
                
                # Skip if we've seen this XPath before
                if xpath in seen_xpaths:
                    continue
                    
                seen_xpaths.add(xpath)
                
                candidate_locator = {
                    "tag": element.name,
                    "class": " ".join(element.get("class", [])),
                    "type": element.get("type", ""),
                    "name": element.get("name", ""),
                    "id": element.get("id", ""),
                    "text": element.get_text(strip=True),
                    "source_page": filename,
                    "xpath": xpath
                }

                # Calculate similarity scores
                similarity_scores = [
                    fuzz.token_sort_ratio(locator, candidate_locator["xpath"]),
                    fuzz.token_sort_ratio(locator, candidate_locator["id"] or ""),
                    fuzz.token_sort_ratio(locator, candidate_locator["class"] or ""),
                    fuzz.partial_ratio(locator, candidate_locator["name"] or ""),
                    fuzz.partial_ratio(locator, candidate_locator["text"] or "")
                ]

                max_similarity = max(similarity_scores)

                if max_similarity >= threshold:
                    best_candidate = {
                        **candidate_locator,
                        "similarity": round(max_similarity, 2)
                    }
                    all_candidates.append(best_candidate)
                    
                    # Only continue searching if we need more candidates
                    if len(all_candidates) >= 10:
                        break
                    
        except Exception as e:
            print(f"Error processing {filename}: {str(e)}")
            continue

    # Sort all candidates by similarity score
    all_candidates = sorted(all_candidates, key=lambda x: x["similarity"], reverse=True)
    
    # Return top 10 candidates or message if none found
    return all_candidates[:10] if all_candidates else [{"message": "No suitable candidates found"}]