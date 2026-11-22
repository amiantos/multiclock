namespace MultiClock;

// A screensaver has no console, so this file is the only place errors go.
public static class Log
{
    static readonly object Sync = new();
    static string? logPath;

    public static void Init()
    {
        try
        {
            Directory.CreateDirectory(AppInfo.DataRoot);
            logPath = Path.Combine(AppInfo.DataRoot, "multiclock.log");
            if (File.Exists(logPath) && new FileInfo(logPath).Length > 2_000_000)
                File.Delete(logPath);
        }
        catch
        {
            // Logging must never take the screensaver down.
        }
    }

    public static void Debug(string message) => Write("DEBUG", message);
    public static void Error(string message) => Write("ERROR", message);

    static void Write(string level, string message)
    {
        var line = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} [{level}] {message}";
        System.Diagnostics.Trace.WriteLine(line);
        if (logPath == null) return;
        try
        {
            lock (Sync) File.AppendAllText(logPath, line + Environment.NewLine);
        }
        catch
        {
        }
    }
}
