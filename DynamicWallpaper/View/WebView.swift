//
// Created by Kensuke Kubo on 2022/12/01.
//

import SwiftUI
import WebKit

extension WKWebView {
    open override var isOpaque: Bool {
        false
    }
}

struct WebView: NSViewRepresentable {
    typealias NSViewType = WKWebView
    
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
}
