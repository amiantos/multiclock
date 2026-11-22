using System.Diagnostics;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using MultiClock.Core;

namespace MultiClock.UI;

// Port of ClockScene.swift + ClusterNode.swift: the 8 x 3 grid of clocks, and
// the frame loop that drives the controller and turns the hands.
public sealed class ClockGridView : Canvas
{
    const int Columns = 8;
    const int Rows = 3;

    public ClockController Controller { get; } = new();

    readonly Settings settings;
    readonly ClockFace[] faces = new ClockFace[ClockController.ClockCount];
    readonly Stopwatch stopwatch = new();
    int texturePixelSize;
    bool running;

    public ClockGridView(Settings settings, bool automatic = true)
    {
        this.settings = settings;
        Background = new SolidColorBrush(settings.BackgroundColorValue);
        ClipToBounds = true;

        Controller.Automatic = automatic;
        Controller.Is24Hour = Is24Hour;

        for (var i = 0; i < faces.Length; i++)
        {
            faces[i] = new ClockFace();
            Children.Add(faces[i]);
        }

        Loaded += (_, _) => StartRendering();
        Unloaded += (_, _) => StopRendering();
        SizeChanged += (_, _) => LayoutClocks();
    }

    // Windows has no single "24-hour time" switch; the user's short time
    // format either uses the 24-hour 'H' specifier or it doesn't.
    static bool Is24Hour() =>
        CultureInfo.CurrentCulture.DateTimeFormat.ShortTimePattern.Contains('H');

    void StartRendering()
    {
        if (running) return;
        running = true;
        LayoutClocks();
        stopwatch.Start();
        Controller.Start();
        CompositionTarget.Rendering += OnRendering;
    }

    void StopRendering()
    {
        if (!running) return;
        running = false;
        stopwatch.Stop();
        CompositionTarget.Rendering -= OnRendering;
    }

    void OnRendering(object? sender, EventArgs e)
    {
        Controller.Tick(stopwatch.Elapsed.TotalSeconds);

        var clocks = Controller.Clocks;
        for (var i = 0; i < faces.Length; i++)
            faces[i].SetHands(clocks[i].Hour.Degrees, clocks[i].Minute.Degrees);
    }

    // The grid spans the full width and is centered vertically, as on macOS.
    // On a screen wider than 8:3 it is limited by height instead, so the
    // clocks never run off the top and bottom.
    //
    // Everything is worked out in physical pixels and converted back, so each
    // clock is a whole number of pixels wide and its artwork is drawn 1:1.
    void LayoutClocks()
    {
        if (ActualWidth <= 0 || ActualHeight <= 0) return;

        var scale = VisualTreeHelper.GetDpi(this).DpiScaleX;
        var widthPx = ActualWidth * scale;
        var heightPx = ActualHeight * scale;

        var clockPx = (int)Math.Floor(Math.Min(widthPx / Columns, heightPx / Rows));
        if (clockPx < 1) return;

        var originX = Math.Round((widthPx - clockPx * Columns) / 2);
        var originY = Math.Round((heightPx - clockPx * Rows) / 2);

        var reloadTextures = clockPx != texturePixelSize;
        var textures = reloadTextures ? new ClockTextures(settings, clockPx) : null;
        texturePixelSize = clockPx;

        for (var i = 0; i < faces.Length; i++)
        {
            // Each cluster is 2 clocks wide and 3 tall; clusters sit side by side.
            var cluster = i / ClockController.ClocksPerCluster;
            var index = i % ClockController.ClocksPerCluster;
            var column = cluster * 2 + index % 2;
            var row = index / 2;

            var face = faces[i];
            face.Width = clockPx / scale;
            face.Height = clockPx / scale;
            SetLeft(face, (originX + column * clockPx) / scale);
            SetTop(face, (originY + row * clockPx) / scale);
            textures?.ApplyTo(face);
        }
    }
}
