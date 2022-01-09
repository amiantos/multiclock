# MultiClock

MultiClock is a screensaver for macOS that displays the current time using 24 clocks. MultiClock is very configurable, with a variety of hand and dial styles and the ability to customize the color of each independently.

## Preview

*Note: This gif has a low framerate. The screensaver itself operates at a fluid 60 FPS.*

![Preview animation of MultiClock screensaver showing 24 clocks rotate to show the numbers 1234, then a pattern, before rotating back to midnight.](/.github/low-framerate-preview.gif?raw=true)![Configuration sheet for the screensaver, showing customizable colors and alternate hand and dial designs](/.github/configure-sheet.png?raw=true)

## Download

* [Download MultiClock v1.0 for macOS](https://amiantos.s3.amazonaws.com/multiclock-1.0.zip)

## Development

1. Clone the repo
2. Open `MultiClock.xcodeproj`
3. The 'macOS' build target allows you to preview the screensaver and control it manually. Take a look at the bottom of `ClockScene.swift` to see some keyboard shortcuts. Add your own to test out animations!

### Adding Animations

If you'd like to add animations to ClockSaver, the public methods on the `Animation` class make it easy--they're very similar to SKActions. For example, a sequence of animations may look like this:

```swift
queue(animations: [
    Animation.display(pattern: inwardPointPattern),
    Animation.wait(duration: 5),
    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225),
    Animation.spinBothHandsWithDelay(by: 180, delay: 0.2),
    Animation.currentTimeClock(),
    Animation.wait(duration: 5),
    Animation.positionBothHands(minuteDegrees: -225, hourDegrees: -225),
    Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0),
    Animation.currentTimePrint(),
])
```

Completed animations should go in `ClockController.swift`. Bump up the `Int.random()` call and add a new `case` to the `switch`. Then submit a PR if you think the animation is cool :)

*Why are all the degree references in negative?* Because I'm too lazy to go back and make them positive after reworking the animation system. Submit a PR fixing it, if you want!

## Authors

* Brad Root - [amiantos](https://github.com/amiantos)

## Credits

MultiClock was inspired by [ClockClock 24](https://clockclock.com/collections/clockclock-24) by [Humans since 1982](https://www.humanssince1982.com). 
