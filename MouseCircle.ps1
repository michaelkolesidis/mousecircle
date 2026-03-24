Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class MouseAPI_06 {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
}
"@

$VK_F8  = 0x77
$VK_ESC = 0x1B

$LEFTDOWN = 0x0002
$LEFTUP   = 0x0004

$radius = 150

Write-Host "MouseCircle"
Write-Host "Move cursor to center, press F8 to draw a left-drag circle."
Write-Host "Press Esc to exit."

while ($true) {

    if ([MouseAPI_06]::GetAsyncKeyState($VK_ESC) -band 0x8000) {
        Write-Host "Exiting..."
        break
    }

    if ([MouseAPI_06]::GetAsyncKeyState($VK_F8) -band 0x8000) {

        # Capture center
        $center = [System.Windows.Forms.Cursor]::Position

        # Choose starting angle (0 radians = right side of circle)
        $startAngle = 0.0

        # Compute starting point of the circle
        $startX = $center.X + [math]::Cos($startAngle) * $radius
        $startY = $center.Y + [math]::Sin($startAngle) * $radius

        # Move cursor directly to the first circle point
        $null = [MouseAPI_06]::SetCursorPos([int]$startX, [int]$startY)

        # Press and hold left click
        [MouseAPI_06]::mouse_event($LEFTDOWN, 0, 0, 0, [UIntPtr]::Zero)

        # Draw circle starting at startAngle
        $angle = $startAngle
        while ($angle -lt (2 * [math]::PI + $startAngle)) {

            $x = $center.X + [math]::Cos($angle) * $radius
            $y = $center.Y + [math]::Sin($angle) * $radius

            $null = [MouseAPI_06]::SetCursorPos([int]$x, [int]$y)

            $angle += 0.05
            Start-Sleep -Milliseconds 10
        }

        # Release left click
        [MouseAPI_06]::mouse_event($LEFTUP, 0, 0, 0, [UIntPtr]::Zero)

        Start-Sleep -Milliseconds 400
    }

    Start-Sleep -Milliseconds 20
}
