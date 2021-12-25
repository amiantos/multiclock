# MultiClock

MultiClock is a screensaver for macOS, and an app for Apple TV, that displays the current time using 24 different clockfaces.

MultiClock was inspired by [ClockClock 24](https://clockclock.com/collections/clockclock-24) by [Humans since 1982](https://www.humanssince1982.com).

## Adding Animations

If you'd like to add animations to ClockSaver, the public methods on the `Animation` class make it easy--they're very similar to SKActions. For example, in the `ClockController`, the command to run a sequence of animations looks like this:

```
queue(animations: [
    Animation.positionBothHands(minuteDegrees: -225, hourDegrees: -225),
    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225),
    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -45),
    Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0),
    Animation.currentTimePrint(),
])
```
