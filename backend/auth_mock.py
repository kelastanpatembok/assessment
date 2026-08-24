#!/usr/bin/env python3
"""
Simple Mock Auth Service for Local Development
Run with: python3 auth_mock.py
"""

from flask import Flask, jsonify, request
import jwt
import time
import os
from datetime import datetime, timedelta

app = Flask(__name__)

# Use the same secret as in .env file
JWT_SECRET = "test-jwt-secret-that-must-be-at-least-32-bytes-long-for-testing-123456"

# In-memory user store for development
users_db = {
    "testuser": {
        "id": "test-user-id-123",
        "username": "testuser",
        "email": "test@example.com",
        "name": "Test User",
        "role": "SUPERADMIN",
        "password": "test123"  # In real app, use hashed passwords
    },
    "gurubk": {
        "id": "gurubk-id-456",
        "username": "gurubk",
        "email": "gurubk@example.com",
        "name": "Guru BK",
        "role": "GURUBK",
        "password": "gurubk123"
    },
    "student": {
        "id": "student-id-789",
        "username": "student",
        "email": "student@example.com",
        "name": "Student Test",
        "role": "SISWA",
        "password": "student123"
    }
}

def generate_token(user_id, username, role):
    """Generate JWT token for user"""
    now = int(time.time())
    payload = {
        'sub': user_id,
        'username': username,
        'role': role,
        'iat': now,
        'exp': now + 3600  # 1 hour expiration
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS512')

@app.route('/api/auth/login', methods=['POST'])
def login():
    """Mock login endpoint"""
    try:
        data = request.json
        if not data:
            return jsonify({
                'error': 'Bad Request',
                'message': 'Request body is required'
            }), 400
        
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({
                'error': 'Bad Request',
                'message': 'Username and password are required'
            }), 400
        
        # Check user in database
        user = users_db.get(username)
        if not user or user['password'] != password:
            return jsonify({
                'error': 'Unauthorized',
                'message': 'Kredensial tidak valid'
            }), 401
        
        # Generate token
        token = generate_token(user['id'], user['username'], user['role'])
        
        return jsonify({
            'token': token,
            'user': {
                'id': user['id'],
                'username': user['username'],
                'email': user['email'],
                'name': user['name'],
                'role': user['role']
            },
            'expiresIn': 3600
        })
    
    except Exception as e:
        return jsonify({
            'error': 'Internal Server Error',
            'message': str(e)
        }), 500

@app.route('/api/auth/register', methods=['POST'])
def register():
    """Mock register endpoint"""
    try:
        data = request.json
        if not data:
            return jsonify({
                'error': 'Bad Request',
                'message': 'Request body is required'
            }), 400
        
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        name = data.get('name')
        role = data.get('role', 'USER')
        
        # Check required fields
        required_fields = ['username', 'email', 'password', 'name']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'error': 'Bad Request',
                    'message': f'{field} is required'
                }), 400
        
        # Check if user exists
        if username in users_db:
            return jsonify({
                'error': 'Conflict',
                'message': 'User already exists'
            }), 409
        
        # Create new user
        user_id = f"user-{int(time.time())}"
        new_user = {
            'id': user_id,
            'username': username,
            'email': email,
            'name': name,
            'role': role,
            'password': password
        }
        
        users_db[username] = new_user
        
        # Generate token
        token = generate_token(user_id, username, role)
        
        return jsonify({
            'token': token,
            'user': {
                'id': user_id,
                'username': username,
                'email': email,
                'name': name,
                'role': role
            },
            'expiresIn': 3600
        })
    
    except Exception as e:
        return jsonify({
            'error': 'Internal Server Error',
            'message': str(e)
        }), 500

@app.route('/api/auth/users/check-existence', methods=['POST'])
def check_usernames_exist():
    """Check if usernames exist"""
    try:
        data = request.json
        usernames = data.get('usernames', [])
        
        existing = []
        for username in usernames:
            if username in users_db:
                existing.append(username)
        
        return jsonify({'existing': existing})
    
    except Exception as e:
        return jsonify({
            'error': 'Internal Server Error',
            'message': str(e)
        }), 500

@app.route('/api/auth/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'UP', 'service': 'auth-mock'})

@app.route('/api/users/<user_id>', methods=['DELETE'])
def delete_user(user_id):
    """Mock delete user endpoint"""
    # In real implementation, this would delete the user
    # For mock, just return success
    return '', 204

@app.route('/api/auth/change-password', methods=['PUT'])
def change_password():
    """Mock change password endpoint"""
    # This endpoint would normally require current password
    # For mock, always return success
    return jsonify({'message': 'Password changed successfully'})

if __name__ == '__main__':
    print("Starting Mock Auth Service on port 2000")
    print("Endpoints available:")
    print("  POST /api/auth/login")
    print("  POST /api/auth/register")
    print("  POST /api/auth/users/check-existence")
    print("  GET  /api/auth/health")
    print("  DELETE /api/users/{userId}")
    print("  PUT /api/auth/change-password")
    print("\nTest users:")
    for username, user in users_db.items():
        print(f"  {username}: {user['role']} (password: {user['password']})")
    
    app.run(host='0.0.0.0', port=2000, debug=True)