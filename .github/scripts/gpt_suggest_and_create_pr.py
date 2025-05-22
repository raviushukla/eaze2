import os
import json
import subprocess
import sys
from pathlib import Path

import httpx
import time
import github
from github import Github
import re

# Global variables
PR_NUMBER = os.environ.get('PR_NUMBER', None)
if not PR_NUMBER and 'GITHUB_REF' in os.environ:
    match = re.search(r'refs/pull/(\d+)/', os.environ['GITHUB_REF'])
    if match:
        PR_NUMBER = match.group(1)

GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')

# Using Gemini API key
GEMINI_API_KEY = os.environ.get('OPEN_API_KEY_2')
REPOSITORY = os.environ.get('GITHUB_REPOSITORY')
MAX_API_RETRIES = 3
API_RETRY_DELAY = 5  # seconds

# Initialize clients
github_client = Github(GITHUB_TOKEN)
repo = github_client.get_repo(REPOSITORY)

# Setup Gemini AI client
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"

# File type configurations - INCLUDE BOTH APEX AND LWC
FILE_TYPES = {
    "apex": {
        "extensions": [".cls", ".trigger"],
        "directory": "force-app",
        "description": "Apex code"
    },
    "lwc": {
        "extensions": [".js", ".html", ".css", ".xml"],
        "directory": "force-app/main/default/lwc",
        "description": "Lightning Web Component"
    },
}

def check_api_key():
    """Check if Gemini API key is valid and working"""
    if not GEMINI_API_KEY: 
        print("GEMINI_API_KEY environment variable is not set. Please ensure 'OPEN_API_KEY_2' is configured correctly.")
        return False
    try:
        with httpx.Client(timeout=10.0) as client:
            # Simple test request to Gemini API
            response = client.post(
                GEMINI_API_URL, 
                json={
                    "contents": [
                        {
                            "parts": [
                                {"text": "Hello"}
                            ]
                        }
                    ],
                    "generationConfig": {
                        "maxOutputTokens": 10
                    }
                }
            )
            response.raise_for_status()
            return True
    except Exception as e:
        print(f"Gemini API key issue: {e}") 
        return False

def load_reports():
    """Load static analysis reports if they exist"""
    reports = {
        "eslint": [],
        "pmd": [],
        "scanner": []
    }
    
    # Load ESLint report
    try:
        if os.path.exists("eslint-report.json"):
            with open("eslint-report.json", "r") as f:
                reports["eslint"] = json.load(f)
    except Exception as e:
        print(f"Error loading ESLint report: {e}")
    
    # Load PMD report
    try:
        if os.path.exists("pmd-report.json"):
            with open("pmd-report.json", "r") as f:
                reports["pmd"] = json.load(f)
    except Exception as e:
        print(f"Error loading PMD report: {e}")
    
    # Load Scanner report
    try:
        if os.path.exists("scanner-report.json"):
            with open("scanner-report.json", "r") as f:
                reports["scanner"] = json.load(f)
    except Exception as e:
        print(f"Error loading Scanner report: {e}")
    
    return reports

def get_file_issues(reports, file_path):
    """Extract issues for a specific file from the reports"""
    issues = []
    
    # Process ESLint issues
    for file_report in reports["eslint"]:
        # Check if file_report is a dictionary and has the expected structure
        if isinstance(file_report, dict) and "filePath" in file_report:
            if file_path in file_report["filePath"]:
                for message in file_report.get("messages", []):
                    issues.append({
                        "line": message.get("line", 0),
                        "message": message.get("message", ""),
                        "severity": message.get("severity", 1),
                        "source": "ESLint"
                    })
        # If file_report is a string (filename), handle it differently
        elif isinstance(file_report, str):
            if file_path in file_report:
                # This might need adjustment based on your ESLint output structure
                issues.append({
                    "line": 0,
                    "message": "Issue found in file",
                    "severity": 1,
                    "source": "ESLint"
                })
    
    # Process PMD issues
    for file_report in reports["pmd"]:
        if isinstance(file_report, dict):
            # Adjust this based on your PMD output structure
            file_name = file_report.get("filename", "")
            if file_path in file_name:
                for violation in file_report.get("violations", []):
                    issues.append({
                        "line": violation.get("beginline", 0),
                        "message": violation.get("description", ""),
                        "severity": 2,  # Assuming medium severity for PMD
                        "source": "PMD"
                    })
    
    # Process Scanner issues
    for issue in reports["scanner"]:
        if isinstance(issue, dict):
            issue_file = issue.get("fileName", "")
            if file_path in issue_file:
                issues.append({
                    "line": issue.get("line", 0),
                    "message": issue.get("message", ""),
                    "severity": issue.get("severity", 1),
                    "source": "SFDX Scanner"
                })
    
    return issues

def identify_file_type(file_path):
    """Identify the type of file based on extension and path"""
    ext = Path(file_path).suffix.lower()
    path = file_path.lower()
    
    for file_type, config in FILE_TYPES.items():
        if ext in config["extensions"] and config["directory"] in path:
            return file_type
    
    # Default to "other" if no match found
    return "other"

def get_modified_project_files():
    """Get all modified Apex and LWC files in the Salesforce project"""
    modified_files = []
    try:
        # Use git command to find all modified files
        cmd = ["git", "diff", "--name-only", "origin/main...HEAD"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        all_files = result.stdout.splitlines()
        
        # Filter for Apex and LWC files
        for file in all_files:
            # Skip directories, git files, and hidden files
            if (not os.path.isfile(file) or 
                file.startswith(".git/") or 
                file.startswith(".")):
                continue
                
            # Check if the file is a recognized type
            file_type = identify_file_type(file)
            if file_type != "other":
                modified_files.append(file)
        
        # Write to file for reference
        with open("modified-salesforce-files.txt", "w") as f:
            for file in modified_files:
                f.write(f"{file}\n")
                
    except Exception as e:
        print(f"Error getting modified project files: {e}")
    
    return modified_files

def read_file_content(file_path):
    """Read content of a file"""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        return ""

def get_related_component_files(file_path):
    """Get all related files for an LWC component"""
    related_files = []
    
    if "lwc" not in file_path:
        return related_files
        
    # Get the component directory
    component_dir = os.path.dirname(file_path)
    
    # Get all files in the component directory
    try:
        for file in os.listdir(component_dir):
            related_path = os.path.join(component_dir, file)
            if os.path.isfile(related_path):
                related_files.append(related_path)
    except Exception as e:
        print(f"Error getting related LWC files: {e}")
    
    return related_files

# def get_fixed_code(file_path, code_content, issues, file_type):
#     """Get AI-fixed code addressing the issues based on file type"""
#     # Determine language based on file extension and type
#     ext = Path(file_path).suffix.lower()
    
#     if file_type == "apex":
#         language = "apex"
#     elif file_type == "lwc":
#         if ext == ".js":
#             language = "javascript"
#         elif ext == ".html":
#             language = "html"
#         elif ext == ".css":
#             language = "css"
#         elif ext == ".xml":
#             language = "xml"
#         else:
#             language = "text"
#     else:
#         language = "text"
    
#     # Create base prompt based on file type
#     if file_type == "apex":
#         prompt = f"""You are a Salesforce development expert. Fix the following {FILE_TYPES.get(file_type, {'description': 'code'})['description']} by addressing all identified issues.

# File: {file_path}

# ```{language}
# {code_content}
# ```

# """
#     elif file_type == "lwc":
#         # For LWC, include additional context about component structure
#         component_name = os.path.basename(os.path.dirname(file_path))
#         file_name = os.path.basename(file_path)
        
#         prompt = f"""You are a Salesforce Lightning Web Components expert. Fix the following {FILE_TYPES.get(file_type, {'description': 'code'})['description']} file by addressing all identified issues.

# Component: {component_name}
# File: {file_name}

# ```{language}
# {code_content}
# ```

# """
#     else:
#         prompt = f"""You are a Salesforce development expert. Fix the following code by addressing all identified issues.

# File: {file_path}

# ```{language}
# {code_content}
# ```

# """

#     # Add issues to prompt
#     if issues:
#         prompt += "Issues that need to be fixed:\n"
#         for issue in issues:
#             prompt += f"\n- Line {issue['line']}: {issue['message']} (Source: {issue['source']})"
#     else:
#         # prompt += f"""No specific issues identified, but please improve the code quality for this {FILE_TYPES.get(file_type, {'description': 'file'})['description']} using Salesforce best practices."""
#         prompt += f"""identify specifc issue and correct it and also improve the code quality for this {FILE_TYPES.get(file_type, {'description': 'file'})['description']} using Salesforce best practices."""

#     # Add specific instructions based on file type
#     if file_type == "apex":
#         prompt += """
        
# Please improve this Apex code by:
# 1. Addressing and modify all identified issues
# 2. Applying Salesforce Apex best practices
# 3. Improving error handling and exception management
# 4. Enhancing code readability and structure
# 5. Optimizing for performance
# 6. Implementing proper security practices (e.g., SOQL injection prevention)
# 7. Adding appropriate comments and documentation
# """
#     elif file_type == "lwc":
#         if ext == ".js":
#             prompt += """
            
# Please improve this LWC JavaScript file by:
# 1. Addressing all identified issues
# 2. Applying Lightning Web Component best practices
# 3. Ensuring proper lifecycle hooks usage
# 4. Implementing proper error handling
# 5. Optimizing performance and reactivity
# 6. Adding appropriate comments and documentation
# 7. Following Salesforce naming conventions
# 8. Using modern JavaScript features appropriately
# """
#         elif ext == ".html":
#             prompt += """
            
# Please improve this LWC HTML template by:
# 1. Addressing all identified issues
# 2. Applying Lightning Web Component best practices
# 3. Ensuring proper data binding usage
# 4. Implementing proper event handling
# 5. Using Salesforce design system components correctly
# 6. Following accessibility best practices
# 7. Structuring markup for performance and readability
# """
#         elif ext == ".css":
#             prompt += """
            
# Please improve this LWC CSS file by:
# 1. Addressing all identified issues
# 2. Following Lightning Design System best practices
# 3. Optimizing CSS specificity and cascading
# 4. Ensuring styles are scoped appropriately
# 5. Using Lightning Design System tokens where appropriate
# 6. Following naming conventions
# 7. Organizing style rules logically
# """
#         elif ext == ".xml":
#             prompt += """
            
# Please improve this LWC configuration file by:
# 1. Addressing all identified issues
# 2. Ensuring proper metadata configuration
# 3. Following Salesforce best practices for configurations
# 4. Validating XML structure and properties
# """

#     prompt += """

# IMPORTANT: Your response should ONLY contain the complete fixed code with no explanations. Return just the code, without the code fence markers (like ```javascript).
# """

#     # Call Gemini API
#     for attempt in range(MAX_API_RETRIES):
#         try:
#             with httpx.Client(timeout=30.0) as client:
#                 response = client.post(
#                     GEMINI_API_URL,
#                     json={
#                         "contents": [
#                             {
#                                 "parts": [
#                                     {"text": prompt}
#                                 ]
#                             }
#                         ],
#                         "generationConfig": {
#                             "temperature": 0.3,
#                             "maxOutputTokens": 4000
#                         }
#                     }
#                 )
#                 response.raise_for_status()
#                 response_data = response.json()
                
#                 # Extract content from Gemini response structure
#                 content = response_data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                
#                 # Remove any markdown code blocks if they exist
#                 content = re.sub(r'```' + language + r'\s*', '', content)
#                 content = re.sub(r'```\s*', '', content)
                
#                 return content.strip()
#         except Exception as e:
#             print(f"Gemini API error (attempt {attempt+1}/{MAX_API_RETRIES}): {e}")
#             if attempt < MAX_API_RETRIES - 1:
#                 print(f"Retrying in {API_RETRY_DELAY} seconds...")
#                 time.sleep(API_RETRY_DELAY)
#             else:
#                 print(f"Failed to get fixed code after {MAX_API_RETRIES} attempts. Error: {e}")
#                 return None


def get_fixed_code(file_path, code_content, issues, file_type):
    """Get AI-fixed code addressing the issues based on file type"""
    # Determine language based on file extension and type
    ext = Path(file_path).suffix.lower()
    
    if file_type == "apex":
        language = "apex"
    elif file_type == "lwc":
        if ext == ".js":
            language = "javascript"
        elif ext == ".html":
            language = "html"
        elif ext == ".css":
            language = "css"
        elif ext == ".xml":
            language = "xml"
        else:
            language = "text"
    else:
        language = "text"
    
    # Create base prompt based on file type
    if file_type == "apex":
        prompt = f"""You are a Salesforce development expert. Your task is to MODIFY and FIX the following {FILE_TYPES.get(file_type, {'description': 'code'})['description']} by making actual changes to address all identified issues.

File: {file_path}

ORIGINAL CODE:
```{language}
{code_content}
```

"""
    elif file_type == "lwc":
        # For LWC, include additional context about component structure
        component_name = os.path.basename(os.path.dirname(file_path))
        file_name = os.path.basename(file_path)
        
        prompt = f"""You are a Salesforce Lightning Web Components expert. Your task is to MODIFY and FIX the following {FILE_TYPES.get(file_type, {'description': 'code'})['description']} file by making actual changes to address all identified issues.

Component: {component_name}
File: {file_name}

ORIGINAL CODE:
```{language}
{code_content}
```

"""
    else:
        prompt = f"""You are a Salesforce development expert. Your task is to MODIFY and FIX the following code by making actual changes to address all identified issues.

File: {file_path}

ORIGINAL CODE:
```{language}
{code_content}
```

"""

    # Add issues to prompt with more specific instructions
    if issues:
        prompt += "\nCRITICAL ISSUES THAT MUST BE FIXED:\n"
        for i, issue in enumerate(issues, 1):
            prompt += f"{i}. Line {issue['line']}: {issue['message']} (Source: {issue['source']})\n"
        
        prompt += f"\nYou MUST fix every single issue listed above. Do not just explain what's wrong - ACTUALLY CHANGE THE CODE to resolve these issues.\n"
    else:
        prompt += f"""\nNo specific issues were identified, but you must still analyze the code and identify any potential problems including:
- Syntax errors
- Logic errors
- Security vulnerabilities
- Performance issues
- Best practice violations
- Code quality improvements

Then ACTUALLY FIX any issues you find in the code."""

    # Add specific instructions based on file type
    if file_type == "apex":
        prompt += """
        
REQUIREMENTS FOR APEX CODE FIXES:
1. ACTUALLY MODIFY the code to fix all identified issues
2. Apply Salesforce Apex best practices by making real changes
3. Fix error handling and exception management (add try-catch blocks if needed)
4. Improve code structure and readability through actual modifications
5. Optimize for performance by changing inefficient code
6. Implement proper security practices (fix SOQL injection vulnerabilities)
7. Add inline comments ONLY where you made changes, using this format:
   // AI_FIXED: [Brief description of what was changed and why]

COMMENT RULES:
- Add "// AI_FIXED: " comments only on lines where you made actual changes
- Keep comments concise but descriptive
- Explain what was wrong and how you fixed it
"""
    elif file_type == "lwc":
        if ext == ".js":
            prompt += """
            
REQUIREMENTS FOR LWC JAVASCRIPT FIXES:
1. ACTUALLY MODIFY the code to fix all identified issues
2. Apply Lightning Web Component best practices through real changes
3. Fix lifecycle hooks usage by correcting the implementation
4. Implement proper error handling by adding actual error handling code
5. Optimize performance and reactivity through code modifications
6. Follow Salesforce naming conventions by renaming variables/methods if needed
7. Use modern JavaScript features by updating outdated syntax
8. Add inline comments ONLY where you made changes, using this format:
   // AI_FIXED: [Brief description of what was changed and why]

COMMENT RULES:
- Add "// AI_FIXED: " comments only on lines where you made actual changes
- Keep comments concise but descriptive
- Explain what was wrong and how you fixed it
"""
        elif ext == ".html":
            prompt += """
            
REQUIREMENTS FOR LWC HTML TEMPLATE FIXES:
1. ACTUALLY MODIFY the template to fix all identified issues
2. Apply Lightning Web Component best practices through real changes
3. Fix data binding usage by correcting the syntax
4. Implement proper event handling by fixing event handlers
5. Use Salesforce design system components correctly
6. Follow accessibility best practices by adding proper attributes
7. Structure markup for better performance and readability
8. Add HTML comments ONLY where you made changes, using this format:
   <!-- AI_FIXED: [Brief description of what was changed and why] -->

COMMENT RULES:
- Add "<!-- AI_FIXED: -->" comments only near lines where you made actual changes
- Keep comments concise but descriptive
- Explain what was wrong and how you fixed it
"""
        elif ext == ".css":
            prompt += """
            
REQUIREMENTS FOR LWC CSS FIXES:
1. ACTUALLY MODIFY the CSS to fix all identified issues
2. Follow Lightning Design System best practices through real changes
3. Fix CSS specificity and cascading issues
4. Ensure styles are scoped appropriately
5. Use Lightning Design System tokens where appropriate
6. Follow naming conventions by renaming classes if needed
7. Organize style rules logically by reordering them
8. Add CSS comments ONLY where you made changes, using this format:
   /* AI_FIXED: [Brief description of what was changed and why] */

COMMENT RULES:
- Add "/* AI_FIXED: */" comments only near lines where you made actual changes
- Keep comments concise but descriptive
- Explain what was wrong and how you fixed it
"""
        elif ext == ".xml":
            prompt += """
            
REQUIREMENTS FOR LWC XML CONFIGURATION FIXES:
1. ACTUALLY MODIFY the XML to fix all identified issues
2. Ensure proper metadata configuration through real changes
3. Follow Salesforce best practices for configurations
4. Fix XML structure and properties
5. Add XML comments ONLY where you made changes, using this format:
   <!-- AI_FIXED: [Brief description of what was changed and why] -->

COMMENT RULES:
- Add "<!-- AI_FIXED: -->" comments only near lines where you made actual changes
- Keep comments concise but descriptive
- Explain what was wrong and how you fixed it
"""

    prompt += f"""

CRITICAL INSTRUCTIONS:
1. You MUST return ONLY the complete modified code
2. DO NOT include any explanations before or after the code
3. DO NOT use code fence markers (like ```{language} or ```)
4. DO NOT include phrases like "Here's the fixed code" or similar
5. ACTUALLY CHANGE the code - don't just return the original code
6. Add "AI_FIXED" comments ONLY on lines where you made actual modifications
7. If no changes are needed, return the original code without any AI_FIXED comments
8. Make sure the returned code is syntactically correct and ready to use

EXAMPLES OF GOOD AI_FIXED COMMENTS:
- // AI_FIXED: Added null check to prevent NullPointerException
- // AI_FIXED: Changed String concatenation to StringBuilder for better performance  
- // AI_FIXED: Added proper exception handling with try-catch block
- /* AI_FIXED: Fixed CSS selector specificity issue */
- <!-- AI_FIXED: Added proper accessibility attributes -->

Remember: Your response should contain ONLY the fixed code with AI_FIXED comments where changes were made. No explanations, no markdown, just the working code.
"""

    # Call Gemini API
    for attempt in range(MAX_API_RETRIES):
        try:
            with httpx.Client(timeout=30.0) as client:
                response = client.post(
                    GEMINI_API_URL,
                    json={
                        "contents": [
                            {
                                "parts": [
                                    {"text": prompt}
                                ]
                            }
                        ],
                        "generationConfig": {
                            "temperature": 0.1,  # Lower temperature for more consistent fixes
                            "maxOutputTokens": 4000,
                            "topP": 0.8,
                            "topK": 10
                        }
                    }
                )
                response.raise_for_status()
                response_data = response.json()
                
                # Extract content from Gemini response structure
                content = response_data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                
                # Clean up the response - remove any markdown code blocks if they exist
                content = re.sub(r'```' + language + r'\s*', '', content)
                content = re.sub(r'```\w*\s*', '', content)  # Remove any code blocks
                content = re.sub(r'^Here.*?code.*?:\s*', '', content, flags=re.IGNORECASE)  # Remove explanation headers
                content = re.sub(r'^.*?fixed.*?code.*?:\s*', '', content, flags=re.IGNORECASE)  # Remove "fixed code" headers
                
                # Validate that we got actual code back
                cleaned_content = content.strip()
                if not cleaned_content:
                    print(f"Warning: Empty response from AI on attempt {attempt+1}")
                    if attempt < MAX_API_RETRIES - 1:
                        continue
                    else:
                        return code_content  # Return original if all attempts fail
                
                # Basic validation: ensure the response looks like code
                if len(cleaned_content) < len(code_content) * 0.5:  # If response is much shorter, might be explanation only
                    print(f"Warning: Response seems too short on attempt {attempt+1}, might be explanation only")
                    if attempt < MAX_API_RETRIES - 1:
                        continue
                
                return cleaned_content
                
        except Exception as e:
            print(f"Gemini API error (attempt {attempt+1}/{MAX_API_RETRIES}): {e}")
            if attempt < MAX_API_RETRIES - 1:
                print(f"Retrying in {API_RETRY_DELAY} seconds...")
                time.sleep(API_RETRY_DELAY)
            else:
                print(f"Failed to get fixed code after {MAX_API_RETRIES} attempts. Error: {e}")
                return code_content  # Return original code if all attempts fail

def get_code_changes_explanation(original_code, fixed_code, issues, file_path, file_type):
    """Get explanation of changes made to the code"""
    # Determine language based on file extension and type
    ext = Path(file_path).suffix.lower()
    
    if file_type == "apex":
        language = "apex"
    elif file_type == "lwc":
        if ext == ".js":
            language = "javascript"
        elif ext == ".html":
            language = "html"
        elif ext == ".css":
            language = "css"
        elif ext == ".xml":
            language = "xml"
        else:
            language = "text"
    else:
        language = "text"
    
    prompt = f"""You are a Salesforce development expert. Explain the changes made to address issues in this {FILE_TYPES.get(file_type, {'description': 'code'})['description']} file ({file_path}).

Original code had these issues:
"""

    # Add issues to prompt
    if issues:
        for issue in issues:
            prompt += f"\n- Line {issue['line']}: {issue['message']} (Source: {issue['source']})"
    else:
        prompt += f"\nNo specific issues identified, but the code was improved for quality."

    prompt += """

I've fixed the code. Provide a clear, concise explanation of:
1. What specific changes were made
2. How the changes address each identified issue
3. Any additional improvements made for code quality

Format your response as markdown with these sections:
- **Summary**: One paragraph overview of key improvements (max 100 words)
- **Primary Fixes**: Bullet points of main issues addressed
- **Technical Details**: Brief explanation of implementation details
- **Best Practices**: Any additional improvements for code quality

Keep your explanation clear and concise - a busy developer should be able to understand the key changes at a glance.
"""

    # Use original_code and fixed_code in the request
    original_code_prompt = f"Original code:\n```{language}\n{original_code}\n```"
    fixed_code_prompt = f"Fixed code:\n```{language}\n{fixed_code}\n```"
    explanation_prompt = "Please explain all the changes made in a format that's easy for developers to quickly understand."
    
    full_prompt = prompt + "\n\n" + original_code_prompt + "\n\n" + fixed_code_prompt + "\n\n" + explanation_prompt

    # Call Gemini API
    for attempt in range(MAX_API_RETRIES):
        try:
            with httpx.Client(timeout=30.0) as client:
                response = client.post(
                    GEMINI_API_URL,
                    json={
                        "contents": [
                            {
                                "parts": [
                                    {"text": full_prompt}
                                ]
                            }
                        ],
                        "generationConfig": {
                            "temperature": 0.5,
                            "maxOutputTokens": 2500
                        }
                    }
                )
                response.raise_for_status()
                response_data = response.json()
                
                # Extract content from Gemini response structure
                return response_data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
        except Exception as e:
            print(f"Gemini API error (attempt {attempt+1}/{MAX_API_RETRIES}): {e}")
            if attempt < MAX_API_RETRIES - 1:
                print(f"Retrying in {API_RETRY_DELAY} seconds...")
                time.sleep(API_RETRY_DELAY)
            else:
                return f"Failed to get explanation after {MAX_API_RETRIES} attempts. Error: {e}"

def write_file_content(file_path, content):
    """Write content to a file"""
    try:
        # Ensure directory exists
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"Error writing to file {file_path}: {e}")
        return False

def analyze_project_structure():
    """Analyze overall project structure for improvement opportunities"""
    print("Analyzing project structure...")
    
    try:
        # Look for key project files and directories
        classes_dir_exists = os.path.exists("force-app/main/default/classes")
        lwc_dir_exists = os.path.exists("force-app/main/default/lwc")
        
        # Collect project metrics
        metrics = {
            "has_apex": classes_dir_exists,
            "has_lwc": lwc_dir_exists
        }
        
        # Count files by type
        file_counts = {
            "apex": 0,
            "lwc": 0,
        }
        
        # Count LWC component metrics
        lwc_components = {}
        
        # Walk through force-app directory
        for root, dirs, files in os.walk("force-app"):
            for file in files:
                file_path = os.path.join(root, file)
                file_type = identify_file_type(file_path)
                if file_type in file_counts:
                    file_counts[file_type] += 1
                
                # Collect LWC component metrics
                if file_type == "lwc":
                    component_name = os.path.basename(os.path.dirname(file_path))
                    if component_name not in lwc_components:
                        lwc_components[component_name] = {"js": False, "html": False, "css": False, "xml": False}
                    
                    ext = Path(file_path).suffix.lower()
                    if ext == ".js":
                        lwc_components[component_name]["js"] = True
                    elif ext == ".html":
                        lwc_components[component_name]["html"] = True
                    elif ext == ".css":
                        lwc_components[component_name]["css"] = True
                    elif ext == ".xml":
                        lwc_components[component_name]["xml"] = True
        
        metrics["file_counts"] = file_counts
        metrics["lwc_components"] = len(lwc_components)
        
        # Check components with missing key files
        incomplete_components = {}
        for component, files in lwc_components.items():
            if not files["js"] or not files["html"]:
                incomplete_components[component] = files
        
        metrics["incomplete_lwc_components"] = incomplete_components
        
        # Save metrics for reference
        with open("project-structure.json", "w") as f:
            json.dump(metrics, f, indent=2)
            
        return metrics
        
    except Exception as e:
        print(f"Error analyzing project structure: {e}")
        return {}

def get_project_improvement_recommendations(project_metrics):
    """Get AI recommendations for project structure improvements"""
    if not project_metrics:
        return ""
    
    prompt = """You are an expert Salesforce DevOps consultant. Analyze this Salesforce project structure and provide specific recommendations for improving the code organization and quality for both Apex and Lightning Web Components.

Project structure metrics:
"""

    # Add project metrics to prompt
    prompt += json.dumps(project_metrics, indent=2)
    
    prompt += """

Based on the project structure, provide recommendations for:
1. Apex code organization and best practices
2. Lightning Web Component organization and best practices
3. Testing improvements for both Apex and LWC
4. Code quality checks and linting
5. Development workflow suggestions

Format your recommendations as markdown with clear, actionable items. Be specific and consider Salesforce DX best practices.
"""

    try:
        with httpx.Client(timeout=30.0) as client:
            response = client.post(
                GEMINI_API_URL,
                json={
                    "contents": [
                        {
                            "parts": [
                                {"text": prompt}
                            ]
                        }
                    ],
                    "generationConfig": {
                        "temperature": 0.5,
                        "maxOutputTokens": 2000
                    }
                }
            )
            response.raise_for_status()
            response_data = response.json()
            
            # Extract content from Gemini response structure
            return response_data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
    except Exception as e:
        print(f"Error getting project recommendations: {e}")
        return "Failed to get project recommendations due to an error."
def create_branch_and_pr_with_fixes(file_changes, project_recommendations=""):
    """Create a new branch with fixes and open a PR to the original branch"""
    # Check if we have any changes
    if not file_changes:
        print("No changes to commit")
        return
    
    try:
        # Create a new branch
        timestamp = int(time.time())
        new_branch = f"ai-salesforce-fixes-{timestamp}"
        
        # Get current branch name as the base branch - this is the branch that opened the PR
        cmd = ["git", "rev-parse", "--abbrev-ref", "HEAD"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        base_branch = result.stdout.strip()
        
        # For PR from GitHub Actions, we need to get the source branch from environment
        source_branch = os.environ.get('SOURCE_BRANCH')
        if source_branch:
            print(f"Using source branch from environment: {source_branch}")
            base_branch = source_branch
        
        print(f"Base branch for AI PR: {base_branch}")
        
        # Create and checkout new branch
        subprocess.run(["git", "checkout", "-b", new_branch])
        
        # Generate changes documentation
        changes_md = "# 🤖 AI Salesforce Code Improvements\n\n"
        changes_md += "This PR contains AI-generated fixes for code issues identified by static analysis tools.\n\n"
        
        # Create structured data for PR comment
        ai_changes_json = []
        modified_files = []
        
        # Process files by type
        file_changes_by_type = {}
        for file_path, change_info in file_changes.items():
            file_type = identify_file_type(file_path)
            if file_type not in file_changes_by_type:
                file_changes_by_type[file_type] = {}
            file_changes_by_type[file_type][file_path] = change_info
        
        # Process Apex files
        if "apex" in file_changes_by_type:
            changes_md += "## Apex Code\n\n"
            
            for file_path, change_info in file_changes_by_type["apex"].items():
                # Write the fixed code to the file
                success = write_file_content(file_path, change_info["fixed_code"])
                if success:
                    modified_files.append(file_path)
                    
                # Add explanation to the markdown
                file_name = Path(file_path).name
                changes_md += f"### {file_name}\n\n"
                changes_md += change_info["explanation"]
                changes_md += "\n\n"
                
                # Get a short summary from the explanation (first paragraph)
                summary_match = re.search(r'(.*?)\n\n', change_info["explanation"], re.DOTALL)
                summary = summary_match.group(1) if summary_match else "Code improvements applied"
                summary = summary.replace('#', '').strip()
                if len(summary) > 100:
                    summary = summary[:97] + "..."
                
                # Count issues fixed
                issues_count = len(get_file_issues(load_reports(), file_path))
                
                # Add to JSON data
                ai_changes_json.append({
                    "file": file_path,
                    "type": "apex",
                    "issues_fixed": issues_count,
                    "summary": summary
                })
        
        # Process LWC files
        if "lwc" in file_changes_by_type:
            changes_md += "## Lightning Web Components\n\n"
            
            # Group LWC files by component
            lwc_components = {}
            for file_path, change_info in file_changes_by_type["lwc"].items():
                component_name = os.path.basename(os.path.dirname(file_path))
                if component_name not in lwc_components:
                    lwc_components[component_name] = []
                lwc_components[component_name].append((file_path, change_info))
            
            # Process each LWC component
            for component_name, files in lwc_components.items():
                changes_md += f"### {component_name}\n\n"
                
                for file_path, change_info in files:
                    # Write the fixed code to the file
                    success = write_file_content(file_path, change_info["fixed_code"])
                    if success:
                        modified_files.append(file_path)
                    
                    # Add explanation to the markdown
                    file_name = Path(file_path).name
                    changes_md += f"#### {file_name}\n\n"
                    changes_md += change_info["explanation"]
                    changes_md += "\n\n"
                    
                    # Get a short summary from the explanation (first paragraph)
                    summary_match = re.search(r'(.*?)\n\n', change_info["explanation"], re.DOTALL)
                    summary = summary_match.group(1) if summary_match else "Code improvements applied"
                    summary = summary.replace('#', '').strip()
                    if len(summary) > 100:
                        summary = summary[:97] + "..."
                    
                    # Count issues fixed
                    issues_count = len(get_file_issues(load_reports(), file_path))
                    
                    # Add to JSON data
                    ai_changes_json.append({
                        "file": file_path,
                        "type": "lwc",
                        "component": component_name,
                        "issues_fixed": issues_count,
                        "summary": summary
                    })
        
        # Add project structure improvements if available
        if project_recommendations:
            changes_md += "## Project Structure Recommendations\n\n"
            changes_md += project_recommendations
            changes_md += "\n\n"
        
        # Write the changes documentation
        with open("ai-changes.md", "w") as f:
            f.write(changes_md)
        
        # Write JSON data for PR comment
        with open("ai-changes.json", "w") as f:
            json.dump(ai_changes_json, f, indent=2)
        
        # Save branch name for reference
        with open("ai-branch-name.txt", "w") as f:
            f.write(new_branch)
        
        # Generate PR comment markdown
        with open("enhancement-comment.md", "w") as f:
            f.write(f"### 🔧 AI Salesforce Code Enhancement Summary\n\n")
            
            apex_files = [item for item in ai_changes_json if item['type'] == 'apex']
            lwc_files = [item for item in ai_changes_json if item['type'] == 'lwc']
            
            total_issues = sum(item['issues_fixed'] for item in ai_changes_json)
            
            summary_text = f"AI has analyzed your code and fixed {len(modified_files)} files with **{total_issues} issues** in a separate branch: `{new_branch}`\n\n"
            
            # Add component counts
            if apex_files:
                summary_text += f"- **{len(apex_files)} Apex files** improved\n"
            
            if lwc_files:
                lwc_components = set(item.get('component') for item in lwc_files if 'component' in item)
                summary_text += f"- **{len(lwc_files)} LWC files** improved across {len(lwc_components)} components\n"
            
            f.write(summary_text + "\n")
            
            # Key improvements
            f.write("#### Key Improvements:\n")
            
            # Get up to 3 examples (prioritizing different types if available)
            examples = []
            if apex_files:
                examples.append(apex_files[0])
            if lwc_files:
                examples.append(lwc_files[0])
            
            # Add more if needed to reach 3
            more_examples = (apex_files + lwc_files)[len(examples):]
            examples.extend(more_examples[:3 - len(examples)])
            
            for example in examples:
                file_name = Path(example["file"]).name
                component_prefix = ""
                if example.get('type') == 'lwc' and example.get('component'):
                    component_prefix = f"[{example.get('component')}] "
                f.write(f"- **{component_prefix}{file_name}**: {example['summary']}\n")
            
            if len(ai_changes_json) > 3:
                f.write(f"- Plus more improvements...\n")
                
            # Add project recommendations notification if available
            if project_recommendations:
                f.write("\n**🏗️ Project Structure**: AI has also provided recommendations for overall code structure improvements. See PR details.\n")
                
        # Commit changes
        subprocess.run(["git", "add", *modified_files, "ai-changes.md", "ai-changes.json", "ai-branch-name.txt"])
        subprocess.run(["git", "config", "--global", "user.email", "github-actions@github.com"])
        subprocess.run(["git", "config", "--global", "user.name", "GitHub Actions"])
        subprocess.run(["git", "commit", "-m", "🤖 Apply AI Salesforce code fixes and improvements"])
        subprocess.run(["git", "push", "origin", new_branch])
        
        # Create PR using GitHub API
        pr_title = "🤖 AI Salesforce Code Improvements"
        
        pr_body = f"""## AI Salesforce Code Improvements

This PR contains AI-generated improvements for Salesforce code, addressing quality issues and implementing best practices.

### Overview
- Improved {len(modified_files)} files
- Addressed {sum(item['issues_fixed'] for item in ai_changes_json)} code quality issues
- Branch: `{new_branch}`

*This PR is automatically generated and can be safely merged.*
"""
        
        # Create PR directly with GitHub API
        repo = github_client.get_repo(REPOSITORY)
        pr = repo.create_pull(
            title=pr_title,
            body=pr_body,
            head=new_branch,
            base=base_branch,  # Target the source branch
            maintainer_can_modify=True  # Allow maintainers to modify
        )
        
        # Save PR number for reference
        with open("ai-pr-number.txt", "w") as f:
            f.write(str(pr.number))
        
        print(f"Created PR #{pr.number}: {pr.html_url}")
        
        # Create a comment with detailed changes
        pr.create_issue_comment(changes_md)
        
    except Exception as e:
        print(f"Error creating branch and PR: {e}")
        # Make sure we return to the original branch
        try:
            subprocess.run(["git", "checkout", base_branch])
        except:
            pass


def main():
    print("Starting AI Salesforce code enhancement process...")
    
    # Check if Gemini API key is valid
    if not check_api_key():
        print("Invalid or missing Gemini API key. Exiting.")
        sys.exit(1)
    
    # Load static analysis reports
    reports = load_reports()
    
    # Get modified Apex and LWC files
    modified_files = get_modified_project_files()
    if not modified_files:
        print("No modified Salesforce files found. Exiting.")
        sys.exit(0)
    
    # Analyze project structure
    project_metrics = analyze_project_structure()
    project_recommendations = ""
    if project_metrics:
        project_recommendations = get_project_improvement_recommendations(project_metrics)
    
    # Process each file
    file_changes = {}
    for file_path in modified_files:
        file_type = identify_file_type(file_path)
        print(f"Processing {file_type} file: {file_path}")
        
        # Read file content
        original_code = read_file_content(file_path)
        if not original_code:
            print(f"Empty or unreadable file: {file_path}. Skipping.")
            continue
        
        # Get issues for this file
        issues = get_file_issues(reports, file_path)
        
        # For Apex, only continue if there are specific issues
        if file_type == "apex" and not issues:
            print(f"No issues found for {file_path}. Skipping.")
            continue
            
        # Get AI-fixed code
        print(f"Generating fixed code for {file_path}...")
        fixed_code = get_fixed_code(file_path, original_code, issues, file_type)
        
        if not fixed_code:
            print(f"Failed to get fixed code for {file_path}. Skipping.")
            continue
            
        if fixed_code == original_code:
            print(f"No changes needed for {file_path}. Skipping.")
            continue
        
        # Get explanation of changes
        print(f"Generating explanation for changes to {file_path}...")
        explanation = get_code_changes_explanation(original_code, fixed_code, issues, file_path, file_type)
        
        # Store the changes
        file_changes[file_path] = {
            "fixed_code": fixed_code,
            "explanation": explanation
        }
    
    # Create branch and PR with fixes
    if file_changes:
        print(f"Creating PR with fixes for {len(file_changes)} files...")
        create_branch_and_pr_with_fixes(file_changes, project_recommendations)
    else:
        print("No changes to commit. Exiting.")


if __name__ == "__main__":
    main()