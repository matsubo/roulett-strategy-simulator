# Roulette Strategy Simulator

## Overview

I have created a simulator for European Roulette in a casino.

When playing roulette, the amount and location of your bets are important. This simulator allows you to simulate the results of executing your betting location strategy and betting amount strategy.

I couldn't find any existing programs or tools that achieve this purpose, so I decided to create one myself.

The program is written in Ruby and uses Gnuplot for graphing. It is Dockerized, so it can be easily used in an environment that can run Docker.

The program is intended to specify the number of plays per day and evaluate the state at the end of the day. After the program finishes executing, the following graph is outputted. The x-axis represents the number of plays, and the y-axis represents the amount of funds. Each line represents one day of play.

The graph shows the results of simulating 360 plays per day for 100 days.

![result](https://user-images.githubusercontent.com/98103/200162790-ff4136e5-4267-4ecd-b087-c14df768bfed.png)

## Requirements

- Docker
- docker-compose

## Setup

```
% git clone git@github.com:matsubo/roulett-strategy-simulator.git
% cd roulett-strategy-simulator
% docker compose build
```

## Run

Executing the simulation

```
% docker compose run app bundle exec ruby main.rb
```

The following statistics are outputted for each day of execution:

```
Draw request: 360 # Number of planned plays
Draw executed: 360 # Number of plays actually executed (cannot play if funds run out)
Max bet: 24 # Maximum bet amount
Bet count: 37 # Number of times participated in play
Bet ratio: 10.278% # Number of times participated in play / Number of plays
Credit: 225 # Final balance
Absolute Drawdown: 77.778% # Maximum drawdown rate of funds
PL(%): 12.5% # Percentage change in funds
Win: 18 # Plays where winnings exceeded the bet amount
Lose: 19 # Plays where winnings were lower than the bet amount
Won(%): 48.649% # Win rate
Seed: 9674385 # Seed value of random number
```

The following statistics are outputted when the entire simulation is completed:

```
Bankrupt: 16 # Number of times balance went below 0
Bankrupt rate: 16.0% # Probability of balance going below 0
```

## System Design

### Basic Design Policy

- The strategy for playing is designed to be modified and executed by changing the program. This is because it is difficult to express the original strategy without writing a program.
- The betting strategy is abstracted, allowing for easy selection of which strategy to use.
- The program is written in an object-oriented manner.

## Class Descriptions

- Roulette::Simulator::PlaySuite
  - Manages the execution of the simulator
- Roulette::Simulator::Account
  - Manages the funds account
- Roulette::Simulator::BetData
  - Manages the locations to bet on
- Roulette::Simulator::Player
  - Manages the plays, including where and how much to bet. The strategy to be used is determined here.
- Roulette::Simulator::Record
  - Records the numbers that have appeared in the past
- Roulette::Simulator::Reward
  - Manages how much to pay out for each bet location
- Roulette::Simulator::Table
  - Represents the roulette table and the names of the locations to bet on
- Roulette::Simulator::Decisions::*
  - Determines the locations and amounts to bet on
