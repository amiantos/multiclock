using System.Globalization;

namespace MultiClock.Core;

// One clock hand. Degrees is its current angle clockwise from 12 o'clock.
public sealed class Hand
{
    public double Degrees;
}

public sealed class ClockState
{
    public readonly Hand Hour = new();
    public readonly Hand Minute = new();
}

// A single hand's share of an animation: after Delay seconds, turn clockwise
// by Delta degrees over Duration seconds.
public sealed class HandMove
{
    public required Hand Hand;
    public double Delay;
    public double From;
    public double Delta;
    public double Duration;

    public double EndTime => Delay + Duration;

    public void Apply(double elapsed)
    {
        var t = elapsed - Delay;
        if (t <= 0) return;
        Hand.Degrees = t >= Duration
            ? ClockAnimation.Normalize(From + Delta)
            : From + Delta * (t / Duration);
    }

    public void Finish() => Hand.Degrees = ClockAnimation.Normalize(From + Delta);
}

// Port of Animations.swift. An animation is a recipe; Build() turns it into
// concrete hand movements from wherever the hands are at that moment. The
// static factories mirror the Swift ones, so sequences in ClockController read
// the same on both platforms.
public sealed class ClockAnimation
{
    enum Kind
    {
        PositionBothHands,
        SpinBothHands,
        SpinBothHandsWithDelay,
        CurrentTimePrint,
        CurrentTimeClock,
        Wait,
        DisplayPattern,
        Print,
    }

    // Radians per second, as in Animations.swift.
    const double MovementSpeed = 0.8;

    readonly Kind kind;
    double degrees;
    double duration;
    double minuteDegrees;
    double hourDegrees;
    double delay;
    Pose[][] pattern = Array.Empty<Pose[]>();
    string text = "0000";

    ClockAnimation(Kind kind) => this.kind = kind;

    // MARK: Factories

    public static ClockAnimation SpinBothHands(double by) =>
        new(Kind.SpinBothHands) { degrees = by };

    public static ClockAnimation PrintString(string text) =>
        new(Kind.Print) { text = text };

    public static ClockAnimation CurrentTimePrint() => new(Kind.CurrentTimePrint);

    public static ClockAnimation CurrentTimeClock() => new(Kind.CurrentTimeClock);

    public static ClockAnimation Wait(double duration) =>
        new(Kind.Wait) { duration = duration };

    public static ClockAnimation PositionBothHands(double minuteDegrees, double hourDegrees) =>
        new(Kind.PositionBothHands) { minuteDegrees = minuteDegrees, hourDegrees = hourDegrees };

    public static ClockAnimation SpinBothHandsWithDelay(double by, double delay) =>
        new(Kind.SpinBothHandsWithDelay) { degrees = by, delay = delay };

    public static ClockAnimation Display(Pose[][] pattern) =>
        new(Kind.DisplayPattern) { pattern = pattern };

    // MARK: Building

    // Fills `moves` and returns how long the whole animation lasts in seconds.
    // `timeSet` is told which time string a CurrentTimePrint is about to show.
    public double Build(
        ClockState[] clocks, List<HandMove> moves, DateTime time, bool is24Hour, Action<string> timeSet)
    {
        switch (kind)
        {
            case Kind.Wait:
                return duration;

            case Kind.SpinBothHands:
                foreach (var clock in clocks) Spin(moves, clock, degrees, 0);
                break;

            case Kind.SpinBothHandsWithDelay:
            {
                // Sweep left to right, one column of three clocks at a time.
                var currentDelay = 0.0;
                for (var cluster = 0; cluster < ClockController.ClusterCount; cluster++)
                {
                    var first = cluster * ClockController.ClocksPerCluster;
                    foreach (var index in new[] { 0, 2, 4 })
                        Spin(moves, clocks[first + index], degrees, currentDelay);
                    currentDelay += delay;
                    foreach (var index in new[] { 1, 3, 5 })
                        Spin(moves, clocks[first + index], degrees, currentDelay);
                    currentDelay += delay;
                }
                break;
            }

            case Kind.PositionBothHands:
                foreach (var clock in clocks) Position(moves, clock, minuteDegrees, hourDegrees);
                break;

            case Kind.CurrentTimePrint:
            {
                var timeString = TimeString(time, is24Hour);
                PrintDigits(moves, clocks, timeString);
                timeSet(timeString);
                break;
            }

            case Kind.Print:
                PrintDigits(moves, clocks, text);
                break;

            case Kind.CurrentTimeClock:
            {
                var minute = time.Minute;
                var hour = time.Hour > 12 ? time.Hour - 12 : time.Hour;
                var hourFloat = hour + minute / 60.0;
                foreach (var clock in clocks)
                    Position(moves, clock, -(360.0 / 60 * minute), -(360.0 / 12 * hourFloat));
                break;
            }

            case Kind.DisplayPattern:
                ShowPattern(moves, clocks, pattern);
                break;
        }

        var total = 0.0;
        foreach (var move in moves) total = Math.Max(total, move.EndTime);
        return total;
    }

    public static string TimeString(DateTime time, bool is24Hour) =>
        time.ToString(is24Hour ? "HHmm" : "hhmm", CultureInfo.InvariantCulture);

    static void PrintDigits(List<HandMove> moves, ClockState[] clocks, string digits)
    {
        var numbers = new Pose[ClockController.ClusterCount][];
        for (var cluster = 0; cluster < numbers.Length; cluster++)
        {
            var digit = cluster < digits.Length && char.IsAsciiDigit(digits[cluster]) ? digits[cluster] - '0' : 0;
            numbers[cluster] = Patterns.Numbers[digit];
        }
        ShowPattern(moves, clocks, numbers);
    }

    static void ShowPattern(List<HandMove> moves, ClockState[] clocks, Pose[][] pattern)
    {
        for (var cluster = 0; cluster < ClockController.ClusterCount && cluster < pattern.Length; cluster++)
        {
            var poses = pattern[cluster];
            for (var index = 0; index < ClockController.ClocksPerCluster && index < poses.Length; index++)
            {
                var clock = clocks[cluster * ClockController.ClocksPerCluster + index];
                Position(moves, clock, poses[index].Minute, poses[index].Hour);
            }
        }
    }

    // MARK: Utils

    static void Position(List<HandMove> moves, ClockState clock, double minuteDegrees, double hourDegrees)
    {
        AddMove(moves, clock.Minute, DegreesBetween(clock.Minute.Degrees, -minuteDegrees), 0);
        AddMove(moves, clock.Hour, DegreesBetween(clock.Hour.Degrees, -hourDegrees), 0);
    }

    static void Spin(List<HandMove> moves, ClockState clock, double degrees, double delay)
    {
        AddMove(moves, clock.Minute, degrees, delay);
        AddMove(moves, clock.Hour, degrees, delay);
    }

    static void AddMove(List<HandMove> moves, Hand hand, double delta, double delay) =>
        moves.Add(new HandMove
        {
            Hand = hand,
            Delay = delay,
            From = hand.Degrees,
            Delta = delta,
            Duration = delta * Math.PI / 180 / MovementSpeed,
        });

    // Hands only ever turn clockwise, so this is the clockwise distance from
    // start to end. Same arithmetic as getRadianDifference in Animations.swift.
    static double DegreesBetween(double startDegrees, double endDegrees)
    {
        if (Math.Abs(startDegrees - endDegrees) < 0.1) return 0;
        return endDegrees >= startDegrees
            ? endDegrees - startDegrees
            : 360 - startDegrees + endDegrees;
    }

    public static double Normalize(double degrees)
    {
        var result = degrees % 360;
        if (result < 0) result += 360;
        // Keep a hand that has come full circle at 0 rather than 359.999...
        return result > 360 - 1e-6 ? 0 : result;
    }
}
