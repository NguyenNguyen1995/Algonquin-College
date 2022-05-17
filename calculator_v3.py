#!/usr/bin/python3

def show_menu():
    """
    display menu options for calculator app
    """
    print("Menu options: ")
    print(" ", "+: to add")
    print(" ", "-: to subtract")
    print(" ", "*: to multiply")
    print(" ", "/: to divide")
    print()

def get_float(prompt_text: str):
    """
    get float number from prompt
    """
    return float(input(prompt_text))

def add(num1 : float, num2: float):
    """
    add two float numbers. Return a float number
    """
    return num1 + num2

def subtract(num1 : float, num2: float):
    """
    subtract two float numbers. Return a float number
    """
    return num1 - num2

def multiply(num1 : float, num2: float):
    """
    multiply two float numbers. Return a float number
    """
    return num1 * num2

def divide(num1 : float, num2: float):
    """
    divide two float numbers. 
    
    if divisor is not zero
        return a float number
    else 
        prompt until get number different from zero

        then return a float number
    """
    # prevent user divide number by 0
    while iszero(num2):
        print("Division by zero cannot be performed.")
        num2 = float(input("Enter a non-zero divisor: "))
        
    return num1 / num2

def iszero(num: float):
    """
    return True if number is zero
    """
    return num == float(0)

def display_result(first_number: float, operator: str, second_number: float, result: float):
    """
    Display calculation as following format:

    -> Result of calculation: {first_number} {operator} {second_number} = {result}
    """
    print("-> Result of calculation:", first_number, operator, second_number, "=", result)

    # for readibility
    print()

# prompts the user for the operator
show_menu()
operator = input("Enter operator (q to quit) [+, -, *, /]: ")

while operator.upper() != "Q":

    # prompts the user for two operands
    first_number = get_float("Enter first number: ")
    second_number = get_float("Enter second number: ")

    # perform the calculation and print the result
    if operator == "+":
        display_result(first_number, operator, second_number, add(first_number, second_number))
    elif operator == "-":
        display_result(first_number, operator, second_number, subtract(first_number, second_number))
    elif operator == "*":
        display_result(first_number, operator, second_number, multiply(first_number, second_number))
    elif operator == "/":
        display_result(first_number, operator, second_number, divide(first_number, second_number))

    # get opeartor again for next calculation or quit
    show_menu()
    operator = input("Enter operator (q to quit) [+, -, *, /]: ")

# print closing message
print("\nThanks for using the program.")