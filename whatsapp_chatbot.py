from flask import Flask, request 
from twilio.twiml.messaging_response import MessagingResponse 
from process_message_chatbot import process_message


 
app = Flask(__name__) 
 
@app.route("/webhook", methods=["POST"]) 
def webhook(): 
    # Get incoming message details 
    incoming_msg = request.values.get('Body', '').strip().lower() 
    sender = request.values.get('From', '') 
     
    # Create a response object 
    resp = MessagingResponse() 
    
     
    resp.message( process_message(incoming_msg,sender))
    return str(resp) 
 
if __name__ == "__main__": 
    app.run(debug=True) 