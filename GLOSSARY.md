# Roulette strategy simulator

Simulates days of European roulette play under a betting strategy, to see how a bankroll behaves over many spins.

## Table

**Spin**:
One turn of the wheel, landing on a number from 0 to 36.
_Avoid_: Draw, result

**Zero**:
The green pocket (0); it lands on no side of any outside bet.

**Outside bet**:
A bet on a group of numbers rather than a single number: color, low/high, even/odd, dozen, or column.
_Avoid_: Bet type, bet location

**Side**:
One of the mutually exclusive groups of an outside bet, such as red or black, or the first, second, or third dozen.
_Avoid_: Location, key

## Strategy

**Strategy**:
The rule that decides the stakes for the next spin from the spin history.
_Avoid_: Decision

**Streak**:
The run of most recent spins that landed on the same side of one outside bet, with zeros skipped.
_Avoid_: Continuous, history

**Trigger**:
The streak length at which the strategy starts betting against the streak.
_Avoid_: Continuous count, threshold

**Stake**:
The amount placed on one side for one spin.
_Avoid_: Bet price, bet

**Lost bet**:
A spin after the trigger was reached on which the strategy's stake lost, either because the streak continued or because the spin was zero.

**Progression**:
The rule that multiplies the stake once per lost bet in the current streak, by the outside bet's payout plus one.
_Avoid_: Martingale (it names only the even-money case)

**Warm-up**:
The opening spins of a day during which the strategy never bets.

## Results

**Day**:
One session of up to a fixed number of spins, starting from the same bankroll; it ends early when the player goes bankrupt.
_Avoid_: Play, suite

**Bankroll**:
The money the player has at the table at a given spin.
_Avoid_: Credit, balance, funds

**Wager**:
Everything staked on one spin, across all sides and bets.

**Bankrupt**:
The state of a day that ended because the bankroll could not cover the next wager, even if some money remains.

**Drawdown**:
The fall of the bankroll from its highest point so far in the day, as a fraction of that high point.

**Return to player**:
The amount returned, stakes included, per unit staked.
_Avoid_: RTP (only as a column heading), payout rate
