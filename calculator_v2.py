#!/usr/bin/python3

# prompts the user for the operator
operator = input("Enter operator (q to quit) [+, -, *, /]: ")

while operator.upper() != "Q":
    # prompts the user for two operands
    first_number = float(input("Enter first number: "))
    second_number = float(input("Enter second number: "))

    # perform the calculation and print the result
    if operator == "+":
        print("-> Result of calculation:", first_number, operator, second_number, "=", first_number + second_number)
    elif operator == "-":
        print("-> Result of calculation:", first_number, operator, second_number, "=", first_number - second_number)
    elif operator == "*":
        print("-> Result of calculation:", first_number, operator, second_number, "=", first_number * second_number)
    elif operator == "/":
        # prevent user divide number by 0
        while second_number == float(0):
            print("Division by zero cannot be performed.")
            second_number = float(input("Enter a non-zero divisor: "))

        print("-> Result of calculation:", first_number, operator, second_number, "=", first_number / second_number)
        
    # get opeartor again for next calculation or quit
    operator = input("Enter operator (q to quit) [+, -, *, /]: ")

# print closing message
print("Thanks for using the program.")