import requests
import json
import os
from datetime import datetime

# Lấy thông tin từ biến môi trường
vm_name = os.getenv("VM_NAME", "default_vm")
login_user = "nguyenluonglinh@vnpt.vn"  # Giá trị cố định hoặc tùy chỉnh
passwd_date = datetime.now().strftime("%Y-%m-%d")

# Define the API endpoint URL
url = "https://infra.vnpt.vn/api/password-history/update"

# Define the headers for the request (required for JSON format)
headers = {
    "Content-Type": "application/json"
}

# Prepare the payload
payload = {
    "login": login_user,  # User thực hiện thay đổi mật khẩu
    "passwd_date": passwd_date,
    "passwd_changed": "Administrator",  # Người dùng bị thay đổi mật khẩu
    "vm": vm_name  # Tên máy chủ nhận từ Ansible
}

# Send the POST request to the API
try:
    response = requests.post(url, headers=headers, data=json.dumps(payload))

    # Check if the request was successful (HTTP status code 200)
    if response.status_code == 200:
        result = response.json()
        print("API Response:", json.dumps(result, indent=4, ensure_ascii=False))
    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")
        print("Response content:", response.content)

except Exception as e:
    print(f"An error occurred: {str(e)}")