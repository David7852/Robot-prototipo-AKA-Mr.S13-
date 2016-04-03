# Mr.S-13

Mr.S-13 is the name of a prototype that me and my classmates developed for the lecture DUM (Design Using Microcomponents). The objective of the project was to develop a car without any kind of sensor attached to it, instead, the controller of the system was placed outside the vehicle and was tasked with monitoring the environment, which was designed as a square board of 16 tiles and special sensors for the edges. Taking such information, the controller must move the car through the board in order to retrieve and object placed randomly in the environment at the beginning of the trial.

An important consideration is that the entire code must be done with assembly language, any other language was banned.

Additionally, the car is supposed to compete against the car of the enemy team; however the cars doesn't know where it is neither have any way to differ which car is its.

# Algorithm's overview

The approach we took was to develop an execution routine discernment routine. Since the controller is incapable of knowing both the initial position and the spin of the car, the discernment routine includes the subroutines to discern which one of the cars it the one to be controlled and also the subroutines to select which execution routine jump to.
The execution routines takes care of retrieving the objective by fixing the initial angle of deflection and moving the car to the most efficient route.

# Discernment
The discernment routine is contained in the "cuerda.asm" file. it was named that way because the concept is similar to what would happens if you took a piece of rope, nail it from one side, and then start pulling the free side. It will, of course, describe a circumference, which area can be described as a collection of vectors connecting every point to the center by a straight line. this concept helps to ensure that, once discovered the estimated distance separating the car from the objective, the car will eventually reach the object and retrieve to its base.
However, this approach is rather rough, and probes to be more effective correcting the spin of the car to a known degree, thus, cuerda.asm is mainly tasked with discovering the first-must convenient known angle that the Execution routine can correct.

As for the identification, the subject was solved establishing start delays, after which the car of every team will begin to move to the enter edge of the board.

# Execution
Execution is a simple path algorithm that uses the static position of the object and the actual position and spin of the car to determinate the must efficient route.
