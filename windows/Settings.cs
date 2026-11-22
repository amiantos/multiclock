using System.Globalization;
using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Windows.Media;

namespace MultiClock;

public static class AppInfo
{
    public const string GitHubUrl = "https://github.com/amiantos/multiclock";
    public const string BradUrl = "https://amiantos.net";

    public static string Version =>
        Assembly.GetExecutingAssembly().GetName().Version?.ToString(3) ?? "1.0.0";

    // %LOCALAPPDATA%\MultiClock — the log file.
    public static string DataRoot => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MultiClock");

    // %APPDATA%\MultiClock\settings.json
    public static string SettingsFile => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "MultiClock", "settings.json");
}

// The names double as the artwork file prefixes (see Textures.cs) and as the
// values written to settings.json.
public enum HandDesign
{
    Modern,
    ModernThin,
    AppleWatchSolid,
    AppleWatchFilled,
    Shout,
    Lcd,
    Traditional,
}

public enum DialDesign
{
    RingThin,
    RingThick,
    RingIndices,
    Indices,
    CutOff,
    None,
}

// Port of Database.swift. Same five settings with the same defaults, stored
// as JSON instead of UserDefaults.
public sealed class Settings
{
    public string HandColor { get; set; } = "#E6E6E6";
    public string DialColor { get; set; } = "#0D0D0D";
    public string BackgroundColor { get; set; } = "#000000";
    public HandDesign HandDesign { get; set; } = HandDesign.Modern;
    public DialDesign DialDesign { get; set; } = DialDesign.RingThin;

    [JsonIgnore] public Color HandColorValue => ParseColor(HandColor, Color.FromRgb(0xE6, 0xE6, 0xE6));
    [JsonIgnore] public Color DialColorValue => ParseColor(DialColor, Color.FromRgb(0x0D, 0x0D, 0x0D));
    [JsonIgnore] public Color BackgroundColorValue => ParseColor(BackgroundColor, Colors.Black);

    static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Converters = { new JsonStringEnumConverter() },
    };

    public static Settings Load()
    {
        try
        {
            if (File.Exists(AppInfo.SettingsFile))
                return JsonSerializer.Deserialize<Settings>(File.ReadAllText(AppInfo.SettingsFile), JsonOptions)
                    ?? new Settings();
        }
        catch (Exception ex)
        {
            Log.Error("Failed to load settings: " + ex.Message);
        }
        return new Settings();
    }

    public void Save()
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(AppInfo.SettingsFile)!);
            File.WriteAllText(AppInfo.SettingsFile, JsonSerializer.Serialize(this, JsonOptions));
        }
        catch (Exception ex)
        {
            Log.Error("Failed to save settings: " + ex.Message);
        }
    }

    public static string FormatColor(Color color) => $"#{color.R:X2}{color.G:X2}{color.B:X2}";

    static Color ParseColor(string? text, Color fallback)
    {
        if (text is { Length: 7 } && text[0] == '#'
            && int.TryParse(text.AsSpan(1), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out var rgb))
        {
            return Color.FromRgb((byte)(rgb >> 16), (byte)(rgb >> 8), (byte)rgb);
        }
        return fallback;
    }
}
