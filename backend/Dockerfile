# Use an official Python runtime as a parent image
# Using slim-bullseye for a smaller image size
FROM python:3.11-slim-bullseye

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
# --no-cache-dir reduces image size
# --upgrade pip ensures we have the latest pip
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container at /app
COPY . .

# Make port 5001 available to the world outside this container
# This is the port Flask runs on inside the container
EXPOSE 5001

# Define environment variable to ensure Python output is sent straight to logs
ENV PYTHONUNBUFFERED=1

# Command to run the application using the Flask development server
# NOTE: We'll ideally switch to gunicorn later for production
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]