-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

-- Window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Push virtual size
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- A blue-ish default RGB background color
BGDEFAULT_R = 0
BGDEFAULT_G = 128
BGDEFAULT_B = 255

-- Standard tile dimensions
TILE_SIZE = 16

-- Briefcase point values
CASE_VALUES = {
    1,
    2,
    5,
    10,
    15,
    20,
    30,
    40,
    50,
    100,
    150,
    200,
    300,
    400,
    500,
    1000,
    1500,
    2000,
    3000,
    4000,
    5000,
    6000,
    7000,
    8000,
    9000,
    10000
}

-- QWERTY key rows stored as lower case.
-- When printed for cases, string.upper() is used.
KEYROW_ONE = {
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'
}
KEYROW_TWO = {
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'
}
KEYROW_THREE = {
    'z', 'x', 'c', 'v', 'b', 'n', 'm'
}
