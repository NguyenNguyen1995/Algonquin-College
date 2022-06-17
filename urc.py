#!/usr/bin/python3

from io import TextIOWrapper
import sys

URCFILE = "Refugee-Ukraine_rev_cumul_date.csv"  # name of the file
UKRAINE_POPULATION = 42_000_000  # Ukrainian population before the conflict
AVG_MIGRATION_RATIO = 3.5  # the global average of people (non-refugee)


def show_menu():
    """
    display menu options
    """
    print()
    print("~ Ukrainian refugee crisis: weekly count (Feb 25 - April 21) ~")
    print("  Note: Data taken from the UN Refugee Agency")
    print("        A. Show weekly refugee count")
    print("        B. Show highest refugee count")
    print("        Q. Quit")
    print()


def get_menu_option(prompt: str):
    """
    get menu option from user

    return lowercase option string
    """
    return input(prompt).strip().lower()


def show_urc(file_handle: TextIOWrapper):
    """
    display all weekly cumulative refugees counts
    """
    print("-> Refugee count per week (February 25 - April 21 2022)")
    
    for line in file_handle.readlines():
        # trim text before split
        data = line.replace('\n', '').strip()
        # ignore newline
        if data:
            data_list = data.split(',')
            print("Date:", f"{data_list[0]}:", data_list[1], "refugees")


def show_max_refugees(file_handle: TextIOWrapper):
    """
    evaluate & display refugee count of the week with the
    highest count

    return line that contains the highest count [date, count]
    """
    max_refugee = 0
    result = []
    for line in file_handle.readlines():
        # trim text before split
        data = line.replace('\n', '').strip()
        # ignore newline
        if data:
            data_list = data.split(',')

            # find the highest count
            if max_refugee < int(data_list[1]):
                max_refugee = int(data_list[1])
                result = data_list
    return result


def calc_percentage(refugee_count: int, ukrainian_population_before_conflict: int):
    """
    calculate the percentage of refugees based on the total
    Ukrainian population before the start of the conflict

    return refugee percentage
    """
    return round(refugee_count / ukrainian_population_before_conflict * 100, 2)


def ishigher(refugee_percentage: float, avg_migration_ratio: float):
    """
    compare refugee percentage and average migration ratio
    
    return True if refugee percentage is higher than average migration
    ratio; False otherwise
    """
    return refugee_percentage > avg_migration_ratio


if __name__ == "__main__":
    try:
        while True:
            show_menu()
            opt = get_menu_option("Enter menu option: ")

            if opt == 'q':
                break
            elif opt == 'a':
                with open(f"./{URCFILE}", "r") as urcfh:
                    show_urc(urcfh)
            elif opt == 'b':
                with open(f"./{URCFILE}", "r") as urcfh:
                    print("-> Date of highest refugee count (February 25 - April 21 2022)")
                    
                    # display the highest count with date associate to it
                    highest_date, highest_count = show_max_refugees(urcfh)
                    print("Highest refugee count:", highest_count, "refugees on", highest_date)
                    
                    # display the percentage of refugees based on the total
                    # Ukrainian population before the start of the conflict
                    ukraine_migration_ratio = calc_percentage(int(highest_count), UKRAINE_POPULATION)
                    print("This represents", ukraine_migration_ratio,
                            "percent of the Ukrainian population before the conflict.")
                    
                    # display comparison between refugee percentage and avg migration ratio
                    if ishigher(ukraine_migration_ratio, AVG_MIGRATION_RATIO):
                        print("This is higher than the average immigration rate of", f"{AVG_MIGRATION_RATIO}%")
                    else:
                        print("This is higher than the average immigration rate of", f"{AVG_MIGRATION_RATIO}%")
            else:
                print("Invalid option.")

        print("Good bye!")
    except Exception as e:
        print("Error:", e)
        print("Exiting program.")
        sys.exit()
