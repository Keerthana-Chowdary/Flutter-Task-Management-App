# Task Management App 

A full-stack Task Management application featuring task dependencies, a modern Glassmorphism UI, and real-time search functionality. 

---

## 🧪 Track & Stretch Goal
- **Chosen Track:** Track A (Full-Stack Builder)
- **Stretch Goal:** Debounced Autocomplete Search (300ms delay with text highlighting)

---

## 🚀 Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Flask (Python)
- **Database:** SQLite (Persistent storage)

---

## ⚙️ Setup Instructions

Follow these steps to get the project running locally.

### 1. Clone the Repository
```bash
git clone https://github.com/Keerthana-Chowdary/Flutter-Task-Management-App
cd Flutter-Task-Management-App
```

### 2. Backend Setup (Flask)
```bash
cd backend
pip install flask flask-cors
python app.py
```
*The server will start at `http://127.0.0.1:5000`*

### 3. Frontend Setup (Flutter)
```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

---

## 📌 Features Implemented

### Core Functionality (CRUD)
- Create, view, update, and delete tasks.
- **Fields:** Title, Description, Due Date, Status (To-Do, In Progress, Done), and Blocked By (Optional).

### Task Dependency Logic
- Tasks remain **inactive** if they are blocked by another task.
- Blocked tasks are visually dimmed and display "Blocked by: Task X".
- Tasks automatically become **active** once the parent task is marked as "Done".

### UI & UX Improvements
- **Glassmorphism UI:** Modern aesthetic with layered visual depth.
- **Loading States:** 2-second simulated delay on create/update to prevent double submissions.
- **Draft Saving:** New task input is automatically saved locally; if you navigate away, your progress is restored.

### Advanced Search & Filter
- **Debounced Search:** Filters tasks by title with a 300ms delay to optimize performance.
- **Status Filter:** Quickly toggle between To-Do, In Progress, and Done views.

---

## 📹 Demo Video
Watch the 1-minute walkthrough demonstrating CRUD operations, dependency logic, and search/filter features.

**[Watch Demo Video Here](https://1drv.ms/v/c/58c371cdbf746713/IQB7vRJd9GPVQph5Pg79aSJQAazsSxjVOrISPsFZ-C37sdE?e=36Apm6)**

---

## 🤖 AI Usage Report
AI tools were used to streamline the development process and assist with UI architecture.

**Specific Uses:**
- Structuring complex Flutter widget trees (specifically the dependency visual cues).
- Debugging API integration and type-safety between Python and Dart.
- Polishing the Glassmorphism styling logic.

**Technical Hurdle Overcome:**
Initially, the "Blocked By" logic was only checking for the existence of a parent task ID. I manually corrected this to dynamically check the *status* of the parent task, ensuring the UI updates in real-time when a blocker is completed.

---

## 💡 Final Note
This project prioritizes a reliable user experience. Features like draft persistence and careful dependency handling ensure the app feels robust and professional. Thank you for your review!
```
