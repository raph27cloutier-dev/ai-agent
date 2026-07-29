import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var toggleVisibilityItem: NSMenuItem?
    private let creature = CreatureController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar-only app: no Dock icon, no app switcher entry.
        NSApp.setActivationPolicy(.accessory)

        setUpStatusItem()
        creature.start()
    }

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "🥔"

        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: "Hide Potato",
            action: #selector(toggleVisibility),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        toggleVisibilityItem = toggleItem

        let comeHereItem = NSMenuItem(
            title: "Come Here",
            action: #selector(comeHere),
            keyEquivalent: ""
        )
        comeHereItem.target = self
        menu.addItem(comeHereItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Potato Buddy",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        statusItem = item
    }

    @objc private func toggleVisibility() {
        creature.toggleVisibility()
        toggleVisibilityItem?.title = creature.isVisible ? "Hide Potato" : "Show Potato"
    }

    @objc private func comeHere() {
        creature.comeHere()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
