# security.py
import os

def authenticate(username, password):
    # Retrieve the stored password from environment variables
    stored_password = 'test'

    # Define a dictionary of users with stored passwords
    all_user = {
        "ram": str(stored_password+'1'),
        "eklavya": stored_password,
        "user1":stored_password,
        "user2":stored_password,
        "user3":stored_password,
        "user4": stored_password,
        "user5": stored_password,
        "user6": stored_password
    }

    # Check if the username exists and if the password matches
    if username in all_user and all_user[username] == password:
        return True
    return False