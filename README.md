# Morse code 
These are a series of Morse code translating programs in Processing.

The two Pison specific programs rely on a pison device with exec running in the background to work. 
DeviceData get's input from execand calls the approriate finger up and finger down functions within the program.

It takes in the finger input as a dit or dah morse signal as determined based off time elapsed and how it compares 
to a running average of expected time amounts. A 'dit' is the short signal in morse and
'Daaaaah' is the long signal. Each are referred to as '1' or '2' in the programs respectively. 

The unique combination of dits and dahs translates that into a letter.

It does so by adding 1s or 2s to a currentLetter counter, which get's converted into a string and
compared to the String [ ] Alphabet to see if there's a match. The match's index value determines the ascii value
of the approriate character.


To test the program without the device handy, open up 'MorseByMouse' and your computer's mouse input can be used as if it were the pison device.

MorsePisonReverseTapping is the most stable with the device, because it treats the index finger lifting up or activating, as if it were the mouse being pressed down. (Think "up finger, down mouse" for why it's called reverse tapping )

If your Processing environment doesn't already have the sound library installed, go up to the top bar, under "Sketch", there's "Import Library" and you can add it from there. Other libraries are available by search if you want to continue adding to this.
