import requests
import json

# Define the API endpoint URL
# url = "http://localhost:6799/api/password-history/get"
url = "https://infra.vnpt.vn/api/password-history/get"

# Define the headers for the request (required for JSON format)
headers = {
    "Content-Type": "application/json"
}

# Prepare the payload (fill only one of application_id, virtual_id, or database_id)
payload = {
    "passwd_changed": "Administrator",  # Example of the password changer
    # Uncomment and fill the one that applies
    # "app": "app_name",  # Example application_id, replace with actual value
    "vm": "DHIT_Hosting_123.30.191.202",    # Example virtual_id, replace with actual value
    # "db": "db_name"    # Example database_id, replace with actual value
}

# Send the GET request to the API
try:
    response = requests.get(url, headers=headers, data=json.dumps(payload))

    # Check if the request was successful (HTTP status code 200)
    if response.status_code == 200:
        # Parse the JSON response
        result = response.json()
        print("API Response:", json.dumps(result, indent=4, ensure_ascii=False))
    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")
        print("Response content:", response.content)

except Exception as e:
    print(f"An error occurred: {str(e)}")
