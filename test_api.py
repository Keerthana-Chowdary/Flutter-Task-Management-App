import requests

BASE_URL = "http://127.0.0.1:5000"

# CREATE TASK
response = requests.post(f"{BASE_URL}/tasks", json={
    "title": "Test Task",
    "description": "Testing without Postman",
    "due_date": "2026-04-01",
    "status": "To-Do",
    "blocked_by": None
})
print("CREATE:", response.json())


# GET TASKS
response = requests.get(f"{BASE_URL}/tasks")
print("GET:", response.json())


# UPDATE TASK (id = 1)
response = requests.put(f"{BASE_URL}/tasks/1", json={
    "status": "Done"
})
print("UPDATE STATUS:", response.status_code)
print("UPDATE TEXT:", response.text)


# DELETE TASK (id = 1)
response = requests.delete(f"{BASE_URL}/tasks/1")
print("DELETE STATUS:", response.status_code)
print("DELETE TEXT:", response.text)