# Boids simulation in Processing 4

## Contains

This program contains a simple boid simulation that contains/will contain the following features:

### Implemented Features

- Basic rules of boids
- Predators that target prey and prey that run away from predators
- Grid partitioning to optimise runtime
- Collision detection using raycasts
- Animal types [DONE]
  - Plankton
  - At least 3 types of fish
  - At least 2 types of sharks
  - 1 type of dolphin [EXTRA]
  - Whales [EXTRA]
  - Animal enum for each type
  - Mapping of data values based on enum
- Animal AI
  - Predators hunt ahead of prey, i.e. they will attempt to intercept the prey
  - Predators do not attempt to hunt prey if being chased
- Debug menu

### TODOs

- Animal AI
  - Danger levels
    - Different levels for different animals. e.g., sharks have universally high levels of danger, but plankton have none, and different fish have different amounts
    - Group and individual. When group danger levels grow too high, cohesion is lowered. If near a "hiding spot" while being chased by a fish (not a predator), it will attempt to hide.
  - Prey hiding in goal areas (e.g., clownfish in sea anemone) if being chased by a predator with a high danger level
    - If being chased, set chased value to true. If not being chased for 5 seconds, set chased value to false. If being chased, head towards home, but react stronger to predator than to home. If no home is set, pick new home when within 500 units. Home is unset after travelling more than 2000 units away.
- Using compute shaders
- Using an quadtree
- Timer class?

## Run Project

### Processing 4+

Download the repository, unzip, and open in Processing.

### Visual Studio Code

Download the repository and unzip. Run the task file in `.vscode/tasks.json` using `Ctrl + Shift + B`. Make sure you have Processing installed and added to your path. The [Processing Language](https://marketplace.visualstudio.com/items?itemName=Tobiah.language-pde) extension was used to generate the task file.
