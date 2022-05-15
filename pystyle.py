#!/usr/bin/python3

# Prompt the user for identification
user_name = input("Please enter your name: ")

# Display a greeting 
print("Welcome to CST8245,", user_name)

# Evaluate user's scripting experience
user_answer = input("Do you have previous scripting experience[Y/N]? ")
if user_answer.upper() == "Y":
    # Display a congratulatory statement
    print("Great.")
else:
    # Display an encouraging statement
    print("Scripting can be fun.")

# Print "Thank you." to user
print("Thank you.")