using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace MultiClock.UI;

// Port of ClockNode.swift: one clock, drawn as three stacked square images —
// hour hand, minute hand, and the dial on top — where the hands rotate about
// the center.
public sealed class ClockFace : Grid
{
    readonly Image hourHand = MakeLayer();
    readonly Image minuteHand = MakeLayer();
    readonly Image dial = MakeLayer();
    readonly RotateTransform hourRotation = new();
    readonly RotateTransform minuteRotation = new();

    public ClockFace()
    {
        hourHand.RenderTransform = hourRotation;
        minuteHand.RenderTransform = minuteRotation;

        Children.Add(hourHand);
        Children.Add(minuteHand);
        Children.Add(dial);
    }

    static Image MakeLayer()
    {
        var image = new Image
        {
            Stretch = Stretch.Fill,
            RenderTransformOrigin = new Point(0.5, 0.5),
        };
        RenderOptions.SetBitmapScalingMode(image, BitmapScalingMode.Linear);
        return image;
    }

    // Angles are degrees clockwise from 12 o'clock.
    public void SetHands(double hourDegrees, double minuteDegrees)
    {
        if (hourRotation.Angle != hourDegrees) hourRotation.Angle = hourDegrees;
        if (minuteRotation.Angle != minuteDegrees) minuteRotation.Angle = minuteDegrees;
    }

    public void SetTextures(ImageSource? hour, ImageSource? minute, ImageSource? dialTexture)
    {
        hourHand.Source = hour;
        minuteHand.Source = minute;
        dial.Source = dialTexture;
    }
}

// The three tinted bitmaps for one combination of settings and size. Every
// clock on a screen shares one set.
public sealed class ClockTextures
{
    public ImageSource? Hour { get; }
    public ImageSource? Minute { get; }
    public ImageSource? Dial { get; }

    public ClockTextures(Settings settings, int pixelSize)
    {
        Hour = Textures.HourHand(settings.HandDesign, pixelSize, settings.HandColorValue);
        Minute = Textures.MinuteHand(settings.HandDesign, pixelSize, settings.HandColorValue);
        Dial = Textures.Dial(settings.DialDesign, pixelSize, settings.DialColorValue);
    }

    public void ApplyTo(ClockFace face) => face.SetTextures(Hour, Minute, Dial);
}
