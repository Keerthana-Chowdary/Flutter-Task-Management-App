from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)


# Task Model
class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100))
    description = db.Column(db.String(200))
    due_date = db.Column(db.String(50))
    status = db.Column(db.String(50))
    blocked_by = db.Column(db.Integer, nullable=True)


# Create DB
with app.app_context():
    db.create_all()


# Routes
@app.route('/')
def home():
    return "Flask is running!"


@app.route('/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.query.all()
    return jsonify([{
        "id": t.id,
        "title": t.title,
        "description": t.description,
        "due_date": t.due_date,
        "status": t.status,
        "blocked_by": t.blocked_by
    } for t in tasks])

@app.route('/tasks/<int:id>', methods=['PUT'])
def update_task(id):
    task = Task.query.get(id)
    data = request.json

    if not task:
        return jsonify({"error": "Task not found"}), 404

    for key in data:
        setattr(task, key, data[key])

    db.session.commit()
    return jsonify({"message": "Task updated"})

@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.json
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return jsonify({"message": "Task created"})

@app.route('/tasks/<int:id>', methods=['DELETE'])
def delete_task(id):
    task = Task.query.get(id)

    if not task:
        return jsonify({"error": "Task not found"}), 404

    db.session.delete(task)
    db.session.commit()

    return jsonify({"message": "Task deleted"})


if __name__ == '__main__':
    app.run(debug=True)