import AppKit

enum IconRenderer {
    static func makeCupIcon(crossed: Bool) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size, flipped: false) { rect in
            let font = NSFont(name: "Apple Color Emoji", size: 16)
                ?? NSFont.systemFont(ofSize: 16)
            let attrString = NSAttributedString(string: "☕", attributes: [.font: font])
            let textSize = attrString.size()
            let origin = NSPoint(
                x: (rect.width - textSize.width) / 2,
                y: (rect.height - textSize.height) / 2
            )
            attrString.draw(at: origin)

            if crossed {
                let inset: CGFloat = 2
                NSColor(calibratedRed: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).setStroke()

                let lineWidth: CGFloat = 2.5

                let diagonal1 = NSBezierPath()
                diagonal1.move(to: NSPoint(x: inset, y: inset))
                diagonal1.line(to: NSPoint(x: rect.width - inset, y: rect.height - inset))
                diagonal1.lineWidth = lineWidth
                diagonal1.lineCapStyle = .round
                diagonal1.stroke()

                let diagonal2 = NSBezierPath()
                diagonal2.move(to: NSPoint(x: rect.width - inset, y: inset))
                diagonal2.line(to: NSPoint(x: inset, y: rect.height - inset))
                diagonal2.lineWidth = lineWidth
                diagonal2.lineCapStyle = .round
                diagonal2.stroke()
            }
            return true
        }
        image.isTemplate = false
        return image
    }
}
