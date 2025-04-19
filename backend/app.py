from flask import Flask, request, jsonify

# Initialize the Flask application
app = Flask(__name__)

# Define a simple route for health checks
@app.route('/')
def health_check():
    """Provides a simple health check endpoint."""
    return jsonify({"status": "ok", "message": "Backend is running"}), 200

# Placeholder for our main translation endpoint (we'll add this later)
@app.route('/translate', methods=['POST'])
def translate_text():
    """Placeholder for the translation logic."""
    # We will replace this with actual logic soon
    data = request.get_json()
    input_text = data.get('text', '') if data else ''
    # Dummy response for now
    output_text = f"(Backend dummy response) Translation for: '{input_text}'"
    return jsonify({"translated_text": output_text})

# Allows running the app directly using 'python app.py'
if __name__ == '__main__':
    # Using port 5001 to avoid potential conflicts with frontend dev server
    app.run(debug=True, port=5001)