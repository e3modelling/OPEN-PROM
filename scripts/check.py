import os
import google.generativeai as genai

def initialize_chat():
    """Initializes the chat with a greeting."""
    model = genai.GenerativeModel("gemini-1.5-flash")
    chat = model.start_chat(
        history=[
            {"role": "user", "parts": "Hello"},
            {"role": "model", "parts": "Great to meet you. How can I assist you today?"},
        ]
    )
    return chat

def continue_chat(chat):
    """Takes user input and sends it to the chat model."""
    while True:
        user_message = input("You: ")
        if user_message.lower() in ['exit', 'quit', 'bye']:
            print("Goodbye!")
            break

        response = chat.send_message(user_message)
        print(f"Bot: {response.text}")

def main():
    # Set up the API key (make sure to set this securely in production)
    os.environ['API_KEY'] = 'your-google-gemini-api-key'
    genai.configure(api_key=os.environ['API_KEY'])

    # Initialize the chat
    chat = initialize_chat()

    # Continue the chat interaction with the user
    continue_chat(chat)

if __name__ == "__main__":
    main()
