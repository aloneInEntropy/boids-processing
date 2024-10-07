# Boids simulation in Processing 4

## Contains

This program contains a simple boid simulation that contains/will contain the following features:

- Basic rules of boids
- Predators that target prey and prey that run away from predators
- Grid partitioning to optimise runtime (unsure if it's implemented correctly)
- Collision detection using raycasts [TODO]
- Animal AI [TODO]
  - Danger levels
    - Different levels for different animals. e.g., sharks have universally high levels of danger, but plankton have none, and different fish has different amounts
    - Group and individual. When group danger levels grow too high, cohesion is lowered. If near a "hiding spot" while being chased by a fish (not a predator), it will attempt to hide. [TODO]
  - Prey hiding in goal areas (e.g., clownfish in sea anemone) if being chased by a it has a high danger level
    - If being chased, set chased value to true. If not being chased for 5 seconds, set chased value to false. If being chased, head towards home, but react stronger to predator than to home. If no home is set, pick new home when within 500 units. Home is unset after travelling more than 2000 units away. [TODO]
  - Predators hunt ahead of prey, i.e. they will attempt to intercept the prey [DONE]
- Animal types [DONE]
  - Plankton
  - At least 3 types of fish
  - At least 2 types of sharks
  - 1 type of dolphin
  - Whales
  - Animal enum for each type
  - Mapping of data values based on enum
- Using on compute shaders [TODO]
- Using an quadtree/octree [TODO]

## Run Project

### Processing 4+

Download the repository, unzip, and open in Processing.

### Visual Studio Code

Download the repository and unzip. Run the task file in `.vscode/tasks.json` using `Ctrl + Shift + B`. Make sure you have Processing installed and added to your path. The [Processing Language](https://marketplace.visualstudio.com/items?itemName=Tobiah.language-pde) extension was used to generate the task file.
