import boto3
import botocore
import json
from flask import Flask, request, jsonify

# Initialize the Flask application
app = Flask(__name__)

# Define a simple route for health checks
@app.route('/')
def health_check():
    """Provides a simple health check endpoint."""
    return jsonify({"status": "ok", "message": "Backend is running"}), 200

# Create a Bedrock Runtime client
try:
    # Ensure you have AWS credentials configured (e.g., via 'aws configure' or environment variables)
    # Also ensure the region set in your AWS config supports Bedrock and the models you want to use.
    bedrock_runtime = boto3.client('bedrock-runtime')
    print("INFO: Bedrock client created successfully.") # Optional: add a print statement for confirmation
except Exception as e:
    # Handle potential client creation errors (e.g., missing credentials, invalid region)
    print(f"ERROR: Could not create Bedrock client: {e}")
    # Depending on your error handling strategy, you might exit or disable functionality
    bedrock_runtime = None # Set to None so checks later can fail gracefully

@app.route('/translate', methods=['POST'])
def translate_text():
    """Translates technical text to business speak using Bedrock."""
    if bedrock_runtime is None:
         print("ERROR: /translate called but Bedrock client is not initialized.")
         return jsonify({"error": "Bedrock client not initialized. Check AWS credentials/region."}), 500

    try:
        # 1. Get input text from the JSON request body
        data = request.get_json()
        if not data or 'text' not in data or not data['text'].strip():
            print("WARN: /translate called with missing or empty 'text'.")
            return jsonify({"error": "Missing or empty 'text' in request body"}), 400
        input_text = data['text']
        print(f"INFO: Received text for translation: {input_text[:100]}...") # Log first 100 chars

        # 2. Choose the Bedrock model
        model_id = 'anthropic.claude-v2' # Sticking with Claude v2 for consistency, v3 Sonnet is also great
        print(f"INFO: Using Bedrock model: {model_id}")

        # 3. Construct the prompt specifically for Tech -> Business translation
        prompt = f"""Human: You are an expert communicator skilled at translating complex technical concepts into clear, concise business language.
                        Take the following technical explanation and rewrite it for a non-technical business audience, focusing on the value proposition, benefits, impact, or key takeaways. Avoid overly technical jargon. Do not include any preamble, just provide the business explanation directly.

                        Technical Text:
                        \"\"\"
                        {input_text}
                        \"\"\"

                        Business Explanation:

                        Assistant:"""
        
        # 4. Format the request body according to the chosen model's requirements (Claude)
        request_body = json.dumps({
            "prompt": prompt,
            "max_tokens_to_sample": 1000,  # Max length of the generated text
            "temperature": 0.5,         # Controls randomness (lower = more focused)
            "top_p": 0.9,               # Nucleus sampling
            "stop_sequences": ["\n\nHuman:"], # Helps prevent model hallucinating more conversation
        })
        print(f"INFO: Sending request to Bedrock model {model_id}.")

        # 5. Invoke the Bedrock model
        response = bedrock_runtime.invoke_model(
            body=request_body,
            modelId=model_id,
            accept='application/json',
            contentType='application/json'
        )
        print(f"INFO: Received response from Bedrock.")

        # 6. Parse the response body
        response_body = json.loads(response.get('body').read())

        # 7. Extract the generated text (specific to Claude response format)
        output_text = response_body.get('completion')

        # 8. Basic cleanup and return
        if output_text:
            output_text = output_text.strip()
            print(f"INFO: Successfully generated translation: {output_text[:100]}...") # Log first 100 chars
            return jsonify({"translated_text": output_text})
        else:
            print("WARN: Received empty completion from Bedrock.")
            return jsonify({"error": "Failed to get translation from model."}), 500
        
    except botocore.exceptions.ClientError as client_error:
        error_code = client_error.response.get('Error', {}).get('Code')
        error_message = client_error.response.get('Error', {}).get('Message')
        print(f"ERROR: AWS ClientError in /translate: {error_code} - {error_message}")
        user_message = f"AWS Error: Could not invoke model ({error_code}). Check permissions or model access in Bedrock console."
        # Specific handling for common errors
        if error_code == 'AccessDeniedException':
            status_code = 403
            user_message = f"AWS Error: Access denied invoking {model_id}. Ensure your IAM role/user has 'bedrock:InvokeModel' permission and access to this model is enabled in Bedrock console."
        elif error_code == 'ThrottlingException':
            status_code = 429 # Too Many Requests
            user_message = "AWS Error: Requests are being throttled. Please try again later."
        elif error_code == 'ModelNotFoundException':
             status_code = 404
             user_message = f"AWS Error: Model {model_id} not found or not accessible in this region. Check model ID and Bedrock model access."
        else:
             status_code = 500 # Generic server error for other client issues

        return jsonify({"error": user_message}), status_code

    except Exception as e:
        # Catch-all for other unexpected errors (e.g., JSON parsing, network issues)
        print(f"ERROR: Unexpected error in /translate: {e}")
        return jsonify({"error": f"An unexpected server error occurred."}), 500

# Allows running the app directly using 'python app.py'
if __name__ == '__main__':
    # Using port 5001 to avoid potential conflicts with frontend dev server
    app.run(debug=True, port=5001)