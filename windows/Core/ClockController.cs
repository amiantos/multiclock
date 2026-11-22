namespace MultiClock.Core;

// Port of ClockController.swift: owns the 24 clocks, runs queued animations
// one after another, and (in automatic mode) decides once a second whether to
// show the new time or play a random flourish.
//
// It has no dependency on WPF. The host calls Tick() every frame with a
// monotonic time in seconds and then draws the hands from Clocks.
public sealed class ClockController
{
    public const int ClusterCount = 4;
    public const int ClocksPerCluster = 6;
    public const int ClockCount = ClusterCount * ClocksPerCluster;

    // Cluster c, clock i lives at Clocks[c * ClocksPerCluster + i].
    public ClockState[] Clocks { get; } = new ClockState[ClockCount];

    // Automatic follows the wall clock; manual only plays what is queued.
    public bool Automatic { get; set; } = true;

    public Func<DateTime> Now { get; set; } = () => DateTime.Now;
    public Func<bool> Is24Hour { get; set; } = () => false;

    readonly Queue<ClockAnimation> animationQueue = new();
    readonly List<HandMove> moves = new();
    bool isAnimating;
    double animationStart;
    double animationDuration;

    bool started;
    double lastUpdate;

    string lastTimeDisplayed = "0000";
    int timeSinceLastAnimation = 30;

    readonly int[] allAnimations;
    readonly List<int> availableAnimations = new();

    public ClockController()
    {
        for (var i = 0; i < Clocks.Length; i++) Clocks[i] = new ClockState();

        allAnimations = Enumerable.Range(1, 9).ToArray();
        Random.Shared.Shuffle(allAnimations);
    }

    bool Busy => isAnimating || animationQueue.Count > 0;

    public void Start()
    {
        if (started) return;
        started = true;
        if (Automatic) Queue(ClockAnimation.CurrentTimePrint());
    }

    public void Queue(params ClockAnimation[] animations)
    {
        foreach (var animation in animations) animationQueue.Enqueue(animation);
    }

    // Advance to `time` (seconds, monotonic).
    public void Tick(double time)
    {
        if (isAnimating)
        {
            var elapsed = time - animationStart;
            if (elapsed >= animationDuration)
            {
                foreach (var move in moves) move.Finish();
                moves.Clear();
                isAnimating = false;
                timeSinceLastAnimation = 0;
            }
            else
            {
                foreach (var move in moves) move.Apply(elapsed);
            }
        }

        if (started && Automatic && time - lastUpdate >= 1)
        {
            lastUpdate = time;
            UpdateTime();
        }

        if (!isAnimating && animationQueue.Count > 0) RunNextAnimation(time);
    }

    void RunNextAnimation(double time)
    {
        var animation = animationQueue.Dequeue();
        moves.Clear();
        animationDuration = animation.Build(Clocks, moves, Now(), Is24Hour(), SetCurrentTime);
        animationStart = time;
        isAnimating = true;
        timeSinceLastAnimation = 0;
    }

    void SetCurrentTime(string time) => lastTimeDisplayed = time;

    // MARK: Timer

    void UpdateTime()
    {
        var timeString = ClockAnimation.TimeString(Now(), Is24Hour());

        timeSinceLastAnimation += 1;

        if (timeString != lastTimeDisplayed && !Busy)
        {
            lastTimeDisplayed = timeString;

            if (timeSinceLastAnimation <= 3)
            {
                Queue(ClockAnimation.CurrentTimePrint());
            }
            else
            {
                Queue(
                    ClockAnimation.SpinBothHands(by: 180),
                    ClockAnimation.CurrentTimePrint());
            }
        }
        else if (timeSinceLastAnimation >= 20 && !Busy)
        {
            if (availableAnimations.Count == 0) availableAnimations.AddRange(allAnimations);

            var number = availableAnimations[^1];
            availableAnimations.RemoveAt(availableAnimations.Count - 1);

            switch (number)
            {
                case 1:
                    // this one is pretty cool imho
                    Queue(
                        ClockAnimation.PositionBothHands(minuteDegrees: -225, hourDegrees: -225),
                        ClockAnimation.PositionBothHands(minuteDegrees: -45, hourDegrees: -225),
                        ClockAnimation.PositionBothHands(minuteDegrees: -45, hourDegrees: -45),
                        ClockAnimation.PositionBothHands(minuteDegrees: 0, hourDegrees: 0),
                        ClockAnimation.CurrentTimePrint());
                    break;
                case 2:
                    // simple time delay 2x full sweep
                    Queue(ClockAnimation.SpinBothHandsWithDelay(by: 720, delay: 0.5));
                    break;
                case 3:
                    // single sweep big delay
                    Queue(ClockAnimation.SpinBothHandsWithDelay(by: 360, delay: 1));
                    break;
                case 4:
                    // inward pointing pattern
                    Queue(
                        ClockAnimation.Display(Patterns.InwardPoint),
                        ClockAnimation.Wait(5),
                        ClockAnimation.SpinBothHands(by: 360),
                        ClockAnimation.Display(Patterns.HalfDownHalfUp),
                        ClockAnimation.SpinBothHands(by: 360),
                        ClockAnimation.PositionBothHands(minuteDegrees: -180, hourDegrees: 0),
                        ClockAnimation.SpinBothHands(by: 180),
                        ClockAnimation.CurrentTimePrint());
                    break;
                case 5:
                    // horizontal lines pattern
                    Queue(
                        ClockAnimation.Display(Patterns.HorizontalLines),
                        ClockAnimation.Wait(10),
                        ClockAnimation.PositionBothHands(minuteDegrees: -90, hourDegrees: -270),
                        ClockAnimation.PositionBothHands(minuteDegrees: -90, hourDegrees: -90),
                        ClockAnimation.PositionBothHands(minuteDegrees: -180, hourDegrees: -180),
                        ClockAnimation.CurrentTimePrint());
                    break;
                case 6:
                    // display randomized clock hand positions
                    Queue(
                        ClockAnimation.Display(Patterns.Randomized()),
                        ClockAnimation.Wait(5),
                        ClockAnimation.SpinBothHands(by: 180),
                        ClockAnimation.CurrentTimePrint());
                    break;
                case 7:
                    // display randomized clock hand positions (right angles only)
                    Queue(
                        ClockAnimation.Display(Patterns.RandomizedRightAngle()),
                        ClockAnimation.Wait(5),
                        ClockAnimation.SpinBothHands(by: 180),
                        ClockAnimation.CurrentTimePrint());
                    break;
                case 8:
                    // display box pattern
                    Queue(
                        ClockAnimation.Display(Patterns.Box),
                        ClockAnimation.Wait(5),
                        ClockAnimation.Display(Patterns.RandomizedRightAngle()),
                        ClockAnimation.SpinBothHands(by: 180),
                        ClockAnimation.CurrentTimePrint());
                    break;
                default:
                    // delay spin with current time as clock
                    Queue(
                        ClockAnimation.PositionBothHands(minuteDegrees: -45, hourDegrees: -225),
                        ClockAnimation.SpinBothHandsWithDelay(by: 180, delay: 0.2),
                        ClockAnimation.CurrentTimeClock(),
                        ClockAnimation.Wait(5),
                        ClockAnimation.PositionBothHands(minuteDegrees: -225, hourDegrees: -225),
                        ClockAnimation.PositionBothHands(minuteDegrees: 0, hourDegrees: 0),
                        ClockAnimation.CurrentTimePrint());
                    break;
            }
        }
    }
}
