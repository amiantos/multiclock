using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Media;

namespace MultiClock.UI;

// Port of ConfigureSheetController.swift + ClockPreviewScene.swift: a live
// preview clock next to the hand, dial and color choices. As on macOS, every
// change is saved the moment it is made.
public class ConfigWindow : Window
{
    const double PreviewSize = 240;

    readonly Settings settings = Settings.Load();

    readonly ClockFace previewClock = new() { Width = PreviewSize, Height = PreviewSize };
    readonly Border previewFrame = new() { Width = PreviewSize, Height = PreviewSize };
    readonly Stopwatch previewTime = Stopwatch.StartNew();

    // Display names in the same order as the macOS popups.
    static readonly (string Name, HandDesign Design)[] HandChoices =
    {
        ("Modern", HandDesign.Modern),
        ("Modern (Thin)", HandDesign.ModernThin),
        ("Apple (Solid)", HandDesign.AppleWatchSolid),
        ("Apple (Filled)", HandDesign.AppleWatchFilled),
        ("Shout", HandDesign.Shout),
        ("LCD", HandDesign.Lcd),
        ("Traditional", HandDesign.Traditional),
    };

    static readonly (string Name, DialDesign Design)[] DialChoices =
    {
        ("Ring (Thin)", DialDesign.RingThin),
        ("Ring (Thick)", DialDesign.RingThick),
        ("Ring (Indices)", DialDesign.RingIndices),
        ("Indices", DialDesign.Indices),
        ("Cut Off", DialDesign.CutOff),
        ("None", DialDesign.None),
    };

    public ConfigWindow()
    {
        Title = "MultiClock Settings";
        SizeToContent = SizeToContent.WidthAndHeight;
        ResizeMode = ResizeMode.NoResize;
        WindowStartupLocation = WindowStartupLocation.CenterScreen;

        previewFrame.Child = previewClock;

        var controls = new StackPanel { Margin = new Thickness(24, 0, 0, 0), Width = 240 };

        controls.Children.Add(new TextBlock
        {
            Text = "MultiClock",
            FontSize = 28,
            FontWeight = FontWeights.Bold,
        });
        controls.Children.Add(new TextBlock
        {
            Text = $"by Brad Root · v{AppInfo.Version} for Windows",
            Foreground = Brushes.Gray,
            Margin = new Thickness(0, 0, 0, 16),
        });

        var handBox = new ComboBox();
        foreach (var choice in HandChoices) handBox.Items.Add(choice.Name);
        handBox.SelectedIndex = Math.Max(0, Array.FindIndex(HandChoices, c => c.Design == settings.HandDesign));
        handBox.SelectionChanged += (_, _) =>
        {
            if (handBox.SelectedIndex < 0) return;
            settings.HandDesign = HandChoices[handBox.SelectedIndex].Design;
            SettingsChanged();
        };

        var dialBox = new ComboBox();
        foreach (var choice in DialChoices) dialBox.Items.Add(choice.Name);
        dialBox.SelectedIndex = Math.Max(0, Array.FindIndex(DialChoices, c => c.Design == settings.DialDesign));
        dialBox.SelectionChanged += (_, _) =>
        {
            if (dialBox.SelectedIndex < 0) return;
            settings.DialDesign = DialChoices[dialBox.SelectedIndex].Design;
            SettingsChanged();
        };

        var grid = new Grid();
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });

        AddRow(grid, "Hands", handBox);
        AddRow(grid, "", MakeColorButton(
            () => settings.HandColorValue,
            color => settings.HandColor = Settings.FormatColor(color)));
        AddRow(grid, "Dial", dialBox);
        AddRow(grid, "", MakeColorButton(
            () => settings.DialColorValue,
            color => settings.DialColor = Settings.FormatColor(color)));
        AddRow(grid, "Background", MakeColorButton(
            () => settings.BackgroundColorValue,
            color => settings.BackgroundColor = Settings.FormatColor(color)));
        controls.Children.Add(grid);

        var top = new StackPanel { Orientation = Orientation.Horizontal };
        top.Children.Add(previewFrame);
        top.Children.Add(controls);

        var doneButton = new Button
        {
            Content = "Done",
            Padding = new Thickness(24, 4, 24, 4),
            IsDefault = true,
            IsCancel = true,
            HorizontalAlignment = HorizontalAlignment.Right,
        };
        doneButton.Click += (_, _) => Close();

        var bottom = new DockPanel { Margin = new Thickness(0, 20, 0, 0) };
        DockPanel.SetDock(doneButton, Dock.Right);
        bottom.Children.Add(doneButton);
        bottom.Children.Add(BuildLinkRow());

        var root = new StackPanel { Margin = new Thickness(24) };
        root.Children.Add(top);
        root.Children.Add(bottom);
        Content = root;

        Loaded += (_, _) =>
        {
            UpdatePreview();
            CompositionTarget.Rendering += OnRendering;
        };
        Closed += (_, _) => CompositionTarget.Rendering -= OnRendering;
    }

    static void AddRow(Grid grid, string label, FrameworkElement control)
    {
        var row = grid.RowDefinitions.Count;
        grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

        var text = new TextBlock
        {
            Text = label,
            VerticalAlignment = VerticalAlignment.Center,
            Margin = new Thickness(0, 0, 12, 0),
        };
        Grid.SetRow(text, row);
        Grid.SetColumn(text, 0);
        grid.Children.Add(text);

        control.Margin = new Thickness(0, 4, 0, 4);
        Grid.SetRow(control, row);
        Grid.SetColumn(control, 1);
        grid.Children.Add(control);
    }

    // A button showing the current color; clicking it opens the standard
    // Windows color picker.
    Button MakeColorButton(Func<Color> get, Action<Color> set)
    {
        var swatch = new Border
        {
            Height = 16,
            MinWidth = 80,
            BorderBrush = Brushes.Gray,
            BorderThickness = new Thickness(1),
            Background = new SolidColorBrush(get()),
        };
        var button = new Button
        {
            Content = swatch,
            Padding = new Thickness(4),
            HorizontalContentAlignment = HorizontalAlignment.Stretch,
        };
        button.Click += (_, _) =>
        {
            var current = get();
            using var dialog = new System.Windows.Forms.ColorDialog
            {
                Color = System.Drawing.Color.FromArgb(current.R, current.G, current.B),
                FullOpen = true,
                AnyColor = true,
            };
            if (dialog.ShowDialog() != System.Windows.Forms.DialogResult.OK) return;

            var picked = Color.FromRgb(dialog.Color.R, dialog.Color.G, dialog.Color.B);
            set(picked);
            swatch.Background = new SolidColorBrush(picked);
            SettingsChanged();
        };
        return button;
    }

    void SettingsChanged()
    {
        settings.Save();
        UpdatePreview();
    }

    void UpdatePreview()
    {
        previewFrame.Background = new SolidColorBrush(settings.BackgroundColorValue);
        var scale = VisualTreeHelper.GetDpi(this).DpiScaleX;
        var pixelSize = Math.Max(1, (int)Math.Round(PreviewSize * scale));
        new ClockTextures(settings, pixelSize).ApplyTo(previewClock);
    }

    // As in ClockPreviewScene: the minute hand goes around every 4 seconds,
    // the hour hand every 48.
    void OnRendering(object? sender, EventArgs e)
    {
        var seconds = previewTime.Elapsed.TotalSeconds;
        previewClock.SetHands(seconds / 48 * 360 % 360, seconds / 4 * 360 % 360);
    }

    static TextBlock BuildLinkRow()
    {
        var block = new TextBlock { VerticalAlignment = VerticalAlignment.Center };

        void AddLink(string text, string url, bool last = false)
        {
            var link = new Hyperlink(new Run(text)) { NavigateUri = new Uri(url) };
            link.RequestNavigate += (_, e) =>
            {
                try
                {
                    Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri) { UseShellExecute = true });
                }
                catch
                {
                }
            };
            block.Inlines.Add(link);
            if (!last) block.Inlines.Add(new Run("    "));
        }

        AddLink("Contribute on GitHub", AppInfo.GitHubUrl);
        AddLink("amiantos.net", AppInfo.BradUrl, last: true);
        return block;
    }
}
