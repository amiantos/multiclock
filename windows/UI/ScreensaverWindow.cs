using System.Windows;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media;
using MultiClock.Core;

namespace MultiClock.UI;

// Port of ClockScreenSaverView.swift: a borderless window covering one
// monitor, showing the clock grid. In windowed test mode it also takes the
// keyboard shortcuts from the bottom of ClockScene.swift.
public class ScreensaverWindow : Window
{
    readonly NativeMethods.RECT boundsPx;
    readonly bool windowed;
    readonly ClockGridView clocks;

    Point? lastMousePosition;

    public ScreensaverWindow(NativeMethods.RECT bounds, bool windowed, Settings settings)
    {
        boundsPx = bounds;
        this.windowed = windowed;

        WindowStyle = WindowStyle.None;
        ResizeMode = ResizeMode.NoResize;
        Background = new SolidColorBrush(settings.BackgroundColorValue);
        ShowInTaskbar = windowed;
        WindowStartupLocation = windowed ? WindowStartupLocation.CenterScreen : WindowStartupLocation.Manual;
        if (windowed)
        {
            Title = "MultiClock (windowed test — press Esc to close)";
            Width = boundsPx.Width;
            Height = boundsPx.Height;
        }
        else
        {
            Topmost = true;
            Cursor = Cursors.None;
        }

        clocks = new ClockGridView(settings);
        Content = clocks;

        SourceInitialized += OnSourceInitialized;

        if (windowed)
        {
            PreviewKeyDown += OnTestKeyDown;
        }
        else
        {
            PreviewKeyDown += (_, _) => ExitScreensaver();
            PreviewMouseDown += (_, _) => ExitScreensaver();
            MouseMove += OnMouseMove;
        }
    }

    void OnSourceInitialized(object? sender, EventArgs e)
    {
        if (windowed) return;
        var hwnd = new WindowInteropHelper(this).Handle;
        NativeMethods.SetWindowPos(
            hwnd, NativeMethods.HWND_TOPMOST,
            boundsPx.Left, boundsPx.Top, boundsPx.Width, boundsPx.Height,
            NativeMethods.SWP_SHOWWINDOW);

        // Record where the window actually landed. If a monitor ever ends up
        // only partly covered — the classic symptom of a DPI scaling mismatch
        // — this line is the evidence.
        if (NativeMethods.GetWindowRect(hwnd, out var placed))
            Log.Debug(
                $"Placed window at ({placed.Left},{placed.Top}) {placed.Width}x{placed.Height}; "
                + $"requested ({boundsPx.Left},{boundsPx.Top}) {boundsPx.Width}x{boundsPx.Height}; "
                + $"DPI {NativeMethods.GetDpiForWindow(hwnd)}");
    }

    void OnMouseMove(object sender, MouseEventArgs e)
    {
        var position = e.GetPosition(this);
        if (lastMousePosition is Point last)
        {
            if (Math.Abs(position.X - last.X) > 10 || Math.Abs(position.Y - last.Y) > 10)
                ExitScreensaver();
        }
        else
        {
            // Ignore the spurious mouse-move Windows delivers as the window opens.
            lastMousePosition = position;
        }
    }

    static void ExitScreensaver() => Application.Current.Shutdown();

    // The same shortcuts as the macOS development app, for trying animations.
    void OnTestKeyDown(object sender, KeyEventArgs e)
    {
        var controller = clocks.Controller;
        switch (e.Key)
        {
            case Key.Escape:
                Close();
                break;
            case Key.Q:
                controller.Queue(
                    ClockAnimation.PrintString("1234"),
                    ClockAnimation.Wait(3),
                    ClockAnimation.Display(Patterns.InwardPoint),
                    ClockAnimation.Wait(3),
                    ClockAnimation.PositionBothHands(minuteDegrees: 0, hourDegrees: -180),
                    ClockAnimation.SpinBothHands(by: 180),
                    ClockAnimation.PositionBothHands(minuteDegrees: 0, hourDegrees: 0));
                break;
            case Key.T:
                controller.Queue(ClockAnimation.CurrentTimePrint());
                break;
            case Key.W:
                controller.Queue(ClockAnimation.PositionBothHands(minuteDegrees: 0, hourDegrees: 0));
                break;
            case Key.X:
                controller.Queue(ClockAnimation.PositionBothHands(minuteDegrees: -45, hourDegrees: -45));
                break;
            case Key.C:
                controller.Queue(ClockAnimation.PositionBothHands(minuteDegrees: -45, hourDegrees: -225));
                break;
            case Key.R:
                controller.Queue(ClockAnimation.CurrentTimeClock());
                break;
            case Key.P:
                controller.Queue(ClockAnimation.SpinBothHands(by: 360));
                break;
            case Key.O:
                controller.Queue(
                    ClockAnimation.Display(Patterns.HorizontalLines),
                    ClockAnimation.Wait(10),
                    ClockAnimation.PositionBothHands(minuteDegrees: -90, hourDegrees: -270),
                    ClockAnimation.PositionBothHands(minuteDegrees: -90, hourDegrees: -90),
                    ClockAnimation.PositionBothHands(minuteDegrees: -180, hourDegrees: -180),
                    ClockAnimation.CurrentTimePrint());
                break;
        }
    }
}
