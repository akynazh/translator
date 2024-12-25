import WebKit

class TranslateWebView: WKWebView {

    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "c":
            self.copy(event)
        case [.command] where event.characters == "v":
            self.paste(event)
        case [.command] where event.characters == "a":
            self.selectAll(event)
        default:
            break
        }
        
        super.keyDown(with: event)
    }
    
    public func keyPress(event: NSEvent){
        super.keyDown(with: event)
    }
    
    @IBAction override func selectAll(_ sender: Any?) {
        super.selectAll(sender)
    }

    @IBAction func copy(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        let script = "window.getSelection().toString()";
        self.evaluateJavaScript(script){ selectedText, error in
            pasteboard.setString(selectedText as! String, forType: .string)
        }
    }

    @IBAction func paste(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        if let copiedString = pasteboard.string(forType: .string) {
            let javascript = "document.execCommand('insertText', false, '\(copiedString)');"
            self.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
    
    
}
