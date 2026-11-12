import Cocoa

/// Arrow coordinates are normalized to the image, so they survive window resizing.
final class ArrowView: NSView {
    private let image: NSImage
    var onArrowsChanged: ((Bool) -> Void)?
    private var arrows: [(CGPoint, CGPoint)] = []
    private var start: CGPoint?
    private var current: CGPoint?

    init(image: NSImage) {
        self.image = image
        super.init(frame: .zero)
        wantsLayer = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) não implementado") }
    override var isFlipped: Bool { true }

    private var imageRect: CGRect {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return bounds }
        let available = bounds.insetBy(dx: 24, dy: 24)
        guard available.width > 0, available.height > 0 else { return .zero }
        let scale = min(available.width / size.width, available.height / size.height)
        let scaled = CGSize(width: size.width * scale, height: size.height * scale)
        return CGRect(x: (bounds.width - scaled.width) / 2, y: (bounds.height - scaled.height) / 2, width: scaled.width, height: scaled.height)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.setFill()
        bounds.fill()
        let rect = imageRect
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
        for (a, b) in arrows { drawArrow(a, b, in: rect, flipped: true) }
        if let a = start, let b = current { drawArrow(a, b, in: rect, flipped: true) }
    }

    private func normalizedPoint(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        CGPoint(x: min(max((point.x - rect.minX) / rect.width, 0), 1), y: min(max((point.y - rect.minY) / rect.height, 0), 1))
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let rect = imageRect
        guard rect.width > 0, rect.height > 0, rect.contains(point) else { return }
        start = normalizedPoint(point, in: rect)
        current = start
    }
    override func mouseDragged(with event: NSEvent) {
        guard start != nil, imageRect.width > 0, imageRect.height > 0 else { return }
        current = normalizedPoint(convert(event.locationInWindow, from: nil), in: imageRect)
        needsDisplay = true
    }
    override func mouseUp(with event: NSEvent) {
        if let a = start, imageRect.width > 0, imageRect.height > 0 {
            let b = normalizedPoint(convert(event.locationInWindow, from: nil), in: imageRect)
            if hypot((b.x - a.x) * imageRect.width, (b.y - a.y) * imageRect.height) > 3 {
                arrows.append((a, b))
                onArrowsChanged?(true)
            }
        }
        start = nil
        current = nil
        needsDisplay = true
    }

    func undoArrow() {
        guard !arrows.isEmpty else { return }
        arrows.removeLast()
        onArrowsChanged?(!arrows.isEmpty)
        needsDisplay = true
    }

    private func drawArrow(_ a: CGPoint, _ b: CGPoint, in rect: CGRect, flipped: Bool) {
        func position(_ p: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + (flipped ? p.y : 1 - p.y) * rect.height)
        }
        let p = position(a), q = position(b)
        let dx = q.x - p.x, dy = q.y - p.y, length = hypot(dx, dy)
        guard length > 0 else { return }
        let width = max(3, min(rect.width, rect.height) * 0.006)
        let head = max(14, width * 4), ux = dx / length, uy = dy / length
        let path = NSBezierPath()
        path.lineWidth = width
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: p)
        path.line(to: q)
        path.move(to: CGPoint(x: q.x - head * ux + head * 0.5 * uy, y: q.y - head * uy - head * 0.5 * ux))
        path.line(to: q)
        path.line(to: CGPoint(x: q.x - head * ux - head * 0.5 * uy, y: q.y - head * uy + head * 0.5 * ux))
        NSColor.systemRed.setStroke()
        path.stroke()
    }

    func renderPNG() -> Data? {
        guard let rep = image.representations.first, rep.pixelsWide > 0, rep.pixelsHigh > 0,
              let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: rep.pixelsWide, pixelsHigh: rep.pixelsHigh, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
              let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        let rect = CGRect(x: 0, y: 0, width: rep.pixelsWide, height: rep.pixelsHigh)
        image.draw(in: rect, from: .zero, operation: .copy, fraction: 1)
        for (a, b) in arrows { drawArrow(a, b, in: rect, flipped: false) }
        NSGraphicsContext.restoreGraphicsState()
        return bitmap.representation(using: .png, properties: [:])
    }
}
