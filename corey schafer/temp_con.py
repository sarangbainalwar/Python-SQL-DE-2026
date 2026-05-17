def f_to_c(f):
    return (f - 32) * 5 / 9

def c_to_f(c):
    return c * 9 / 5 + 32


start = 0

while start != 1:

    i1 = input("enter f or c: ").strip().lower()

    if i1 == 'f':
        i2 = float(input("enter temp in fahrenheit to convert to celsius: "))
        print(f_to_c(i2))

    elif i1 == 'c':
        i2 = float(input("enter temp in celsius to convert to fahrenheit: "))
        print(c_to_f(i2))

    else:
        print("invalid input")

    s = input("enter e to exit or any other key to continue: ").strip().lower()

    if s == 'e':
        start = 1
        print("goodbye")