#!/usr/bin/env swift

import AppKit

// Generate app icon from SF Symbol "sun.max"
let size: CGFloat = 1024
let symbolName = "sun.max.fill"

guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
    print("Failed to load SF Symbol: \(symbolName)")
    exit(1)
}

// Create a new image with the desired size
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

// Fill with gradient background (orange tones similar to Claude)
let gradient = NSGradient(colors: [
    NSColor(red: 0.95, green: 0.55, blue: 0.35, alpha: 1.0),  // Light orange
    NSColor(red: 0.85, green: 0.40, blue: 0.25, alpha: 1.0)   // Darker orange
])!
gradient.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: -45)

// Configure symbol
let config = NSImage.SymbolConfiguration(pointSize: size * 0.55, weight: .regular)
let symbolImage = symbol.withSymbolConfiguration(config)!

// Draw symbol centered in white
let symbolSize = symbolImage.size
let x = (size - symbolSize.width) / 2
let y = (size - symbolSize.height) / 2

NSColor.white.setFill()
symbolImage.draw(
    in: NSRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height),
    from: .zero,
    operation: .sourceOver,
    fraction: 1.0
)

image.unlockFocus()

// Get script directory and output path
let scriptPath = CommandLine.arguments[0]
let scriptDir = (scriptPath as NSString).deletingLastPathComponent
let projectDir = (scriptDir as NSString).deletingLastPathComponent
let outputPath = "\(projectDir)/ClaudeUsage/Resources/AppIcon.png"

// Save as PNG
guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Failed to create PNG data")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Icon saved to: \(outputPath)")
} catch {
    print("Failed to save icon: \(error)")
    exit(1)
}
