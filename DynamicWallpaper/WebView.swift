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

    let webView: WKWebView

    init(url: String) {
        webView = WKWebView(frame: .zero)

        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        webView.setValue(false, forKey: "drawsBackground")
    }

    func makeNSView(context: Context) -> WKWebView {
        webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
