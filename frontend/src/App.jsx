import { useState } from 'react';
import axios from 'axios'; // Import axios
import './App.css'; // Keep the CSS import (even if file is empty for now)

function App() {
  // State variables to hold our data
  const [inputText, setInputText] = useState(''); // For the technical text input
  const [outputText, setOutputText] = useState(''); // For the translated business text
  const [isLoading, setIsLoading] = useState(false); // To show loading state on button

  // Function to handle form submission
  const handleSubmit = async (event) => {
    event.preventDefault(); // Prevent default browser form submission
    setIsLoading(true);     // Set loading state to true
    setOutputText('');      // Clear previous output

    try {
      
       // Define the URL for our local backend endpoint
       const backendUrl = 'http://localhost:5001/translate';

       console.log("INFO: Sending text to backend:", inputText);
 
       // Make the POST request using axios
       // Send the input text in the request body as JSON
       const response = await axios.post(backendUrl, {
         text: inputText, // The key 'text' must match what the Flask backend expects
       });
 
       // Set the output text state variable with the data received from the backend
       console.log("INFO: Received response from backend:", response.data);
       if (response.data && response.data.translated_text) {
           setOutputText(response.data.translated_text);
       } else {
           // Handle cases where backend might not return the expected field
           console.error("ERROR: Unexpected response format from backend:", response.data);
           setOutputText("Error: Received unexpected data from server.");
       }

    } catch (error) {
      console.error("Error submitting text:", error);
      // In a real app, you'd show a user-friendly error message
      setOutputText("An error occurred during translation.");
    } finally {
      // This block runs whether the try succeeded or failed
      setIsLoading(false); // Set loading state back to false
    }
  };

  // The JSX structure of our component (what gets rendered)
  return (
    <div className="App">
      <h1>Tech <span style={{color: '#4CAF50'}}>to</span> Business Translator</h1> {/* Added some basic inline style */}

      {/* The form for input */}
      <form onSubmit={handleSubmit}>
        <div>
          <textarea
            rows="8" // Made textarea larger
            cols="70" // Made textarea wider
            value={inputText}
            onChange={(e) => setInputText(e.target.value)} // Update state on change
            placeholder="Enter technical explanation here..."
            required // Make input required
          />
        </div>
        <button type="submit" disabled={isLoading}>
          {/* Show different button text based on loading state */}
          {isLoading ? 'Translating...' : 'Translate to Business Speak'}
        </button>
      </form>

      {/* Display the output only if outputText is not empty */}
      {outputText && ( // Conditionally render this section
        <div className="output-section"> {/* Added class for potential styling */}
          <h2>Business Explanation:</h2>
          {/* Using a pre tag preserves whitespace/newlines which might be nice for output */}
          <pre className="output-text">{outputText}</pre>
        </div>
      )}
    </div>
  );
}

export default App; // Export the component so it can be used