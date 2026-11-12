import Cocoa
import UniformTypeIdentifiers

final class EditorWindowController: NSWindowController, NSWindowDelegate {
    private let canvas: ArrowView
    private var undoButton: NSButton!

    init(image: NSImage) {
        canvas = ArrowView(image: image)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700), styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        super.init(window: window)
        window.title = "Editar captura"
        window.minSize = NSSize(width: 620, height: 420)
        window.center()
        window.delegate = self

        let container = NSView()
        window.contentView = container

        let heading = NSTextField(labelWithString: "Sua captura")
        heading.font = .systemFont(ofSize: 18, weight: .semibold)
        let instruction = NSTextField(labelWithString: "Arraste sobre a imagem para desenhar uma seta.")
        instruction.font = .systemFont(ofSize: 12)
        instruction.textColor = .secondaryLabelColor
        let titles = NSStackView(views: [heading, instruction])
        titles.orientation = .vertical
        titles.alignment = .leading
        titles.spacing = 3
        titles.translatesAutoresizingMaskIntoConstraints = false

        func button(_ title: String, symbol: String, action: Selector) -> NSButton {
            let button = NSButton(title: title, target: self, action: action)
            button.bezelStyle = .rounded
            button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
            button.imagePosition = .imageLeading
            return button
        }
        undoButton = button("Desfazer", symbol: "arrow.uturn.backward", action: #selector(undoArrow))
        undoButton.toolTip = "Desfazer a última seta"
        undoButton.isEnabled = false
        canvas.onArrowsChanged = { [weak self] hasArrows in self?.undoButton.isEnabled = hasArrows }

        let saveButton = button("Salvar PNG…", symbol: "square.and.arrow.down", action: #selector(saveImage))
        let copyButton = button("Copiar", symbol: "doc.on.doc", action: #selector(copyImage))
        copyButton.keyEquivalent = "c"
        copyButton.keyEquivalentModifierMask = .command
        copyButton.toolTip = "Copiar imagem e fechar (⌘C)"
        copyButton.bezelColor = .controlAccentColor
        let actions = NSStackView(views: [undoButton, saveButton, copyButton])
        actions.orientation = .horizontal
        actions.alignment = .centerY
        actions.spacing = 8
        actions.translatesAutoresizingMaskIntoConstraints = false

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        canvas.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titles)
        container.addSubview(actions)
        container.addSubview(separator)
        container.addSubview(canvas)
        NSLayoutConstraint.activate([
            titles.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22),
            titles.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            actions.leadingAnchor.constraint(greaterThanOrEqualTo: titles.trailingAnchor, constant: 16),
            actions.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            actions.centerYAnchor.constraint(equalTo: titles.centerYAnchor),
            separator.topAnchor.constraint(equalTo: titles.bottomAnchor, constant: 17),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            canvas.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            canvas.topAnchor.constraint(equalTo: separator.bottomAnchor),
            canvas.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) não implementado") }
    @objc private func undoArrow() { canvas.undoArrow() }
    @objc private func copyImage() {
        guard let data = pngData() else { return }
        NSPasteboard.general.clearContents()
        if NSPasteboard.general.setData(data, forType: .png) {
            window?.close()
        }
    }
    @objc private func saveImage() {
        guard let data = pngData(), let window = window else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "Captura.png"
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            do { try data.write(to: url) } catch { NSAlert(error: error).runModal() }
        }
    }
    private func pngData() -> Data? {
        guard let data = canvas.renderPNG() else {
            let alert = NSAlert()
            alert.messageText = "Não foi possível gerar a imagem."
            alert.runModal()
            return nil
        }
        return data
    }
    func windowWillClose(_ notification: Notification) {
        (NSApp.delegate as? AppDelegate)?.removeEditor(self)
    }
}
