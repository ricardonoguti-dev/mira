import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var editors: [EditorWindowController] = []
    private var capturing = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let icon = NSImage(systemSymbolName: "viewfinder", accessibilityDescription: "Mira — capturas de tela")
            icon?.isTemplate = true
            button.image = icon
            button.imagePosition = .imageOnly
            button.toolTip = "Mira — capturas de tela"
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "Capturar área…", action: #selector(captureArea), keyEquivalent: "a")
        menu.addItem(withTitle: "Capturar tela inteira", action: #selector(captureScreen), keyEquivalent: "t")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Sobre o Mira", action: #selector(about), keyEquivalent: "")
        menu.addItem(withTitle: "Sair do Mira", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    @objc private func captureArea() { capture(interactive: true) }
    @objc private func captureScreen() { capture(interactive: false) }

    private func capture(interactive: Bool) {
        guard !capturing else { return }
        capturing = true
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("mira-\(UUID().uuidString).png")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = (interactive ? ["-i", "-x"] : ["-x", "-m"]) + [url.path]
        process.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.capturing = false
                defer { try? FileManager.default.removeItem(at: url) }
                guard let image = NSImage(contentsOf: url) else {
                    // An interactive capture can end without a file when the user presses Esc.
                    if !interactive || process.terminationStatus != 0 {
                        self.showError("Não foi possível capturar a tela. Verifique a permissão de gravação de tela nos Ajustes do Sistema.")
                    }
                    return
                }
                let editor = EditorWindowController(image: image)
                self.editors.append(editor)
                editor.showWindow(nil)
                editor.window?.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        do { try process.run() } catch {
            capturing = false
            showError(error.localizedDescription)
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Mira"
        alert.informativeText = message
        alert.runModal()
    }

    func removeEditor(_ editor: EditorWindowController) {
        editors.removeAll { $0 === editor }
    }

    @objc private func about() {
        let alert = NSAlert()
        alert.messageText = "Mira"
        alert.informativeText = "Capturas com setas, direto da barra de menus.\n\nNa primeira captura, o macOS pode solicitar permissão de gravação de tela. Para cancelar uma seleção, pressione Esc."
        alert.runModal()
    }

    @objc private func quit() { NSApp.terminate(nil) }
}
