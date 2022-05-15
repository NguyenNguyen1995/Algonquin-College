#!/usr/bin/python3

# Prompts the user for the operator
op = input("Enter operator [+, -, *, /]: ")

# Prompts the user for two operands
first_number = float(input("Enter first number: "))
second_number = float(input("Enter second number: "))

# Performs the calculation based on user input
if op == "+":
    result = first_number + second_number
elif op == "-":
    result = first_number - second_number
elif op == "*":
    result = first_number * second_number
elif op == "/":
    # Handle case the divisor is zero
    if second_number == float(0):
        result = None
        print("Division by zero cannot be performed.")
    else:
        result = first_number / second_number
# Handle case invalid arithmetic operations
else:
    result = None
    print("Invalid arithmetic operations")

# Print the calculation result for the user
if result == None:
    print("-> Result of calculation:", first_number, op, second_number,"=", result)

# Print closing message
print("Thanks for using the program.")