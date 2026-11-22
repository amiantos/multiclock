using System.Reflection;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace MultiClock.UI;

// Port of Textures.swift plus the tinting SpriteKit did for us. The artwork is
// white-on-transparent (with a little black in the "filled" hands); SpriteKit
// colored it with colorBlendFactor = 1, which multiplies every pixel by the
// chosen color. WPF has no such blend, so the multiply happens here, once,
// when a texture is loaded.
public static class Textures
{
    public static BitmapSource? HourHand(HandDesign design, int pixelSize, Color tint) =>
        Load(Prefix(design.ToString()) + "HourHand", pixelSize, tint);

    public static BitmapSource? MinuteHand(HandDesign design, int pixelSize, Color tint) =>
        Load(Prefix(design.ToString()) + "MinuteHand", pixelSize, tint);

    public static BitmapSource? Dial(DialDesign design, int pixelSize, Color tint) =>
        design == DialDesign.None ? null : Load(Prefix(design.ToString()) + "Dial", pixelSize, tint);

    // HandDesign.ModernThin -> "modernThin", matching the file names in Assets.
    static string Prefix(string name) => char.ToLowerInvariant(name[0]) + name[1..];

    // Decodes the named square PNG at exactly pixelSize x pixelSize, so it is
    // drawn 1:1 on screen, and multiplies it by the tint color.
    static BitmapSource? Load(string name, int pixelSize, Color tint)
    {
        try
        {
            using var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(name + ".png");
            if (stream == null)
            {
                Log.Error($"Missing artwork: {name}.png");
                return null;
            }

            var decoded = new BitmapImage();
            decoded.BeginInit();
            decoded.CacheOption = BitmapCacheOption.OnLoad;
            decoded.DecodePixelWidth = pixelSize;
            decoded.DecodePixelHeight = pixelSize;
            decoded.StreamSource = stream;
            decoded.EndInit();

            // Bgra32 is straight (non-premultiplied) alpha, so the color
            // channels can be multiplied without touching transparency.
            var source = new FormatConvertedBitmap(decoded, PixelFormats.Bgra32, null, 0);
            var width = source.PixelWidth;
            var height = source.PixelHeight;
            var stride = width * 4;
            var pixels = new byte[stride * height];
            source.CopyPixels(pixels, stride, 0);

            for (var i = 0; i < pixels.Length; i += 4)
            {
                pixels[i] = (byte)(pixels[i] * tint.B / 255);
                pixels[i + 1] = (byte)(pixels[i + 1] * tint.G / 255);
                pixels[i + 2] = (byte)(pixels[i + 2] * tint.R / 255);
            }

            var tinted = BitmapSource.Create(width, height, 96, 96, PixelFormats.Bgra32, null, pixels, stride);
            tinted.Freeze();
            return tinted;
        }
        catch (Exception ex)
        {
            Log.Error($"Failed to load artwork {name}: {ex.Message}");
            return null;
        }
    }
}
