import Cocoa
import WebKit

class TranslateViewController: NSViewController, WKNavigationDelegate {
    @IBOutlet var webView: TranslateWebView!
    @IBOutlet var webViewContainer: NSView!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var popOverViewController: NSPopover!
    
    override var acceptsFirstResponder: Bool { return false }
    
    var urlLoaded = false
    let defaultUrl = "https://translate.google.com?sl=auto&tl=zh-CN&text="
    
    override func viewWillAppear() {
        super.viewWillAppear()

        progressIndicator.display()
        
        if (!self.urlLoaded) {
            self.urlLoaded = true
            webView.load(NSURLRequest(url: NSURL(string: defaultUrl)! as URL) as URLRequest)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressIndicator.isHidden = true
    }
    
    
    public func loadText(text: String){
        if (webView != nil){
            webView.load(getTranslateURL(textToTranslate: text))
        }
    }
    
    public func getTranslateURL(textToTranslate: String) -> URLRequest{
        
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
        let sanitizedInput = textToTranslate.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? textToTranslate
        
        let urlString = String(format: "%@%@", defaultUrl, sanitizedInput)
        let url = URL(string: urlString)
        return NSURLRequest(url: url ?? URL(string: defaultUrl)!) as URLRequest
    }

    public override func keyDown(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "c",
             [.command ] where event.characters == "v",
             [.command ] where event.characters == "a":
            ()
        default:
            break
        }
    }

}
