# Deal50

My final project for [CS50's Introduction to Game Development](https://github.com/games50/).

A LÖVE2D game inspired by the _Deal or No Deal_ TV show!

You have 26 containers to choose from, with each one randomly shuffled upon starting the game and assigned its own letter corresponding to your keyboard. Are you able to score the 10,000-point container?

There are up to 9 rounds, and you start by opening 6 containers at a time before being given an offer by the scoremaster: a cat with a suit and tie. If you deny the offer, for each other round you then open X minus 1 containers (Minimum one).

The offers given by the scoremaster are based on an algorithm that is influenced by the amount of containers that are yet to be opened, their values, the rate of cases to open in the round, and how generous the scoremaster is at the moment.

To win the game, you must land a good offer should you decide to take on what the scoremaster is willing to provide (Your container's value is less than the scoremaster's offer), or if you decline all offers from the scoremaster and you have the largest value container versus the one that has yet to be opened by the end.

Inspiration for this project came from my interest in game shows, and developing an adaptation of one in the spirit of a CS50 game felt like a natural fit for the course. The game's complexity stems from its heavy use of timer calls for fades, tile movements, and other scripted animations. The scoremaster's algorithm had to be fine tuned several times to provide reasonable offers during normal gameplay. There is also the visual cohesiveness from the start screen to playing the first round, and from the result screen to the game over screen, despite having moved through different states!

## Controls:
| Key              |          Command |
|:-----------------|-----------------:|
| Space            |        Do Action |
| A-Z              | Select Container |
| Left/Right Arrow | Highlight Option |
| Esc              |        Quit Game |

## Prerequisites:
* [LÖVE 0.10.2](https://github.com/love2d/love/releases/tag/0.10.2)

## External Libraries & Assets:
* [Knife](https://github.com/airstruck/knife)
* [Hump (class.lua)](https://github.com/vrld/hump)
* [Push v0.2 (push.lua)](https://github.com/Ulydev/push)
* Music by Kevin MacLeod (incompetech.com)<br>
Licensed under Creative Commons: By Attribution 4.0 License<br>
http://creativecommons.org/licenses/by/4.0/.
* [Fipps](https://pheist.net/fonts.php?id=51) freeware typeface font by Stefanie Koerner (pheist.net).

Based on the USA version of the TV show by Endemol International B.V.
