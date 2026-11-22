namespace MultiClock.Core;

// Where one clock's two hands point, in the same convention as Patterns.swift:
// degrees are negative-clockwise from 12 o'clock, so -90 is 3 o'clock.
public readonly record struct Pose(double Hour, double Minute);

// Port of Patterns.swift. A pattern is four clusters of six clocks; within a
// cluster the clocks run left-to-right, top-to-bottom (2 columns x 3 rows).
public static class Patterns
{
    // Six (hour, minute) pairs, written flat so the tables below read like the
    // Swift originals.
    static Pose[] Cluster(params double[] values)
    {
        var poses = new Pose[values.Length / 2];
        for (var i = 0; i < poses.Length; i++)
            poses[i] = new Pose(values[i * 2], values[i * 2 + 1]);
        return poses;
    }

    public static readonly Pose[][] InwardPoint =
    {
        Cluster(-105, -105, -115, -115,
                -90, -90, -90, -90,
                -75, -75, -65, -65),
        Cluster(-125, -125, -150, -150,
                -90, -90, -90, -90,
                -55, -55, -30, -30),
        Cluster(-210, -210, -235, -235,
                -270, -270, -270, -270,
                -330, -330, -305, -305),
        Cluster(-245, -245, -255, -255,
                -270, -270, -270, -270,
                -295, -295, -285, -285),
    };

    public static readonly Pose[][] HalfDownHalfUp =
    {
        Cluster(-180, -180, -180, -180,
                -180, -180, -180, -180,
                -180, -180, -180, -180),
        Cluster(-180, -180, -180, -180,
                -180, -180, -180, -180,
                -180, -180, -180, -180),
        Cluster(0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0),
        Cluster(0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0),
    };

    public static readonly Pose[][] HorizontalLines =
    {
        Cluster(-90, -90, -270, -90,
                -90, -90, -270, -90,
                -90, -90, -270, -90),
        Cluster(-270, -90, -270, -90,
                -270, -90, -270, -90,
                -270, -90, -270, -90),
        Cluster(-270, -90, -270, -90,
                -270, -90, -270, -90,
                -270, -90, -270, -90),
        Cluster(-270, -90, -270, -270,
                -270, -90, -270, -270,
                -270, -90, -270, -270),
    };

    public static readonly Pose[][] Box =
    {
        Cluster(-90, -180, -270, -90,
                0, -180, -90, -90,
                0, -90, -270, -90),
        Cluster(-270, -90, -270, -90,
                -270, -90, -270, -90,
                -270, -90, -270, -90),
        Cluster(-270, -90, -270, -90,
                -270, -90, -270, -90,
                -270, -90, -270, -90),
        Cluster(-270, -90, -270, -180,
                -270, -270, 0, -180,
                -270, -90, 0, -270),
    };

    // Digits 0-9, indexed by digit.
    public static readonly Pose[][] Numbers =
    {
        Cluster(-90, -180, -270, -180,
                -180, 0, -180, 0,
                -90, 0, -270, 0),
        Cluster(-225, -225, -180, -180,
                -225, -225, -180, 0,
                -225, -225, 0, 0),
        Cluster(-90, -90, -270, -180,
                -180, -90, -270, 0,
                0, -90, -270, -270),
        Cluster(-90, -90, -270, -180,
                -90, -90, 0, -270,
                -90, -90, -270, 0),
        Cluster(-180, -180, -180, -180,
                0, -90, 0, -180,
                -225, -225, 0, 0),
        Cluster(-180, -90, -270, -270,
                0, -90, -270, -180,
                -90, -90, -270, 0),
        Cluster(-180, -90, -270, -270,
                0, -180, -270, -180,
                0, -90, 0, -270),
        Cluster(-90, -90, -270, -180,
                -225, -225, -180, 0,
                -225, -225, 0, 0),
        Cluster(-90, -180, -270, -180,
                -90, 0, -270, 0,
                0, -90, -270, 0),
        Cluster(-90, -180, -270, -180,
                -90, 0, 0, -180,
                -90, -90, -270, 0),
    };

    public static Pose[][] Randomized() =>
        Generate(() => Random.Shared.Next(-359, 1));

    public static Pose[][] RandomizedRightAngle()
    {
        double[] options = { 0, -90, -180, -270 };
        return Generate(() => options[Random.Shared.Next(options.Length)]);
    }

    static Pose[][] Generate(Func<double> angle)
    {
        var pattern = new Pose[ClockController.ClusterCount][];
        for (var cluster = 0; cluster < pattern.Length; cluster++)
        {
            pattern[cluster] = new Pose[ClockController.ClocksPerCluster];
            for (var clock = 0; clock < pattern[cluster].Length; clock++)
                pattern[cluster][clock] = new Pose(angle(), angle());
        }
        return pattern;
    }
}
