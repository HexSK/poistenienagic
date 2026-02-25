import turtle
import random
import math

def trojuholniky(strana):

    uhol = random.randint(-20, 20)
    pero.setheading(uhol)

    vyska = math.sqrt(3) * strana / 2

    pero.penup()
    pero.backward(strana / 2)
    pero.pendown()

    for _ in range(3):
        pero.forward(strana)
        pero.left(120)
    pero.penup()
    pero.forward(strana / 2)
    pero.pendown()

    pero.setheading(90)
    pero.penup()
    pero.forward(vyska)
    pero.pendown()

platno = turtle.Screen()
platno.bgcolor('white')
pero = turtle.Turtle()
pero.shape("turtle")
pero.color('blue')
pero.speed(3)
pero.penup()
pero.goto(0, -platno.window_height() / 2 + 20)
pero.pendown()
pocet = random.randint(3, 7)
for _ in range(pocet):
    velkost = random.randint(30, 100)
    trojuholniky(velkost)

platno.mainloop()