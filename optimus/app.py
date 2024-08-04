import logging
import os
from datetime import timedelta

from flask import Flask, render_template, request, redirect, url_for, session
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

from security import authenticate

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Configure SQLAlchemy to use PostgreSQL
# app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('url') +'&sslrootcert=./root.crt'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = '9f2dGt6%#3sqv8@x1f@WUk'  # Set a secret key for sessions
# Set session timeout to one hour
app.permanent_session_lifetime = timedelta(hours=1)
# db = SQLAlchemy(app)

# Set up logging
logging.basicConfig(level=logging.DEBUG,  # Set the logging level
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
logger.info("\n\n\n\nLogging.\n\n\n")

# Log the current working directory
logger.debug(f"Current working directory: {os.getcwd()}")
# List files in the current working directory
logger.debug(f"Files in the current directory: {os.listdir(os.getcwd())}")
# List files in the templates directory
logger.debug(f"Files in the templates directory: {os.listdir(os.path.join(os.getcwd(), 'templates'))}")

@app.route('/')
def home():
    logger.debug("Home route accessed")
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    logger.debug("Login route accessed")
    if request.method == 'POST':
        logger.debug("Login POST method")
        username = request.form.get('username')
        password = request.form.get('password')
        logger.debug(f"Received username: {username}")
        if authenticate(username=username, password=password):
            # Set authenticated session
            logger.debug("Authentication successful")
            session['authenticated'] = True
            session['username'] = username  # Store the username
            session.permanent = True
            return redirect(url_for('index'))
        else:
            logger.debug("Authentication failed")
            return render_template('invalid.html')
    logger.debug("Login GET method")
    return render_template('login.html')

if __name__ == "__main__":
    logger.debug("Starting Flask application")
    app.run(host="0.0.0.0", port=5001, debug=True)
