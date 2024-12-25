import Cocoa
import KeyboardShortcuts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    let translateViewController = TranslateViewController(nibName: "TranslateViewController", bundle: nil)
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("MenuTranslate: starting")
        
        KeyboardShortcuts.onKeyUp(for: .toggleApp) {
            self.showPopover(sender: nil)
        }
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("TranslateMenuImage"))
            button.action = #selector(statusItemButtonActivated(sender:))
            button.sendAction(on: [ .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp ])
        }
        
        popover.contentViewController = translateViewController
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        eventMonitor?.start()
        
        NSApplication.shared.servicesProvider = self
        NSLog("MenuTranslate: started")

    }
    
    @IBAction
    func statusItemButtonActivated(sender: AnyObject?) {
        let buttonMask = NSEvent.pressedMouseButtons
        var primaryDown = ((buttonMask & (1 << 0)) != 0)
        var secondaryDown = ((buttonMask & (1 << 1)) != 0)
        
        // Treat a control-click as a secondary click
        if (primaryDown && (NSEvent.modifierFlags == NSEvent.ModifierFlags.control)) {
            primaryDown = false;
            secondaryDown = true;
        }
        
        if (primaryDown) {
            if popover.isShown {
                closePopover(sender: sender)
            } else {
                showPopover(sender: sender)
            }
        } else if (secondaryDown) {
            statusItem.menu = self.statusMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        }
    }
    
    func showPopover(sender: AnyObject?, keyword : String? = nil) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc func translateService(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        let text = pasteboard.string(forType: .string)
        translateViewController.loadText(text: text!)
        self.showPopover(sender: nil, keyword: text)
    }
    
    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction
    func aboutMenuActivated(sender: AnyObject?) {
        NSWorkspace().open(URL(string: "https://github.com/akynazh/osx-translator")!)
    }
    
}
