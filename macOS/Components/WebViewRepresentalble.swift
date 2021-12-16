//
//  WebViewRepresentalble.swift
//  Portal (macOS)
//
//  Created by Farid on 28.09.2021.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    private let baseUrl: String = "https://cryptomarket-api.herokuapp.com/exchange/tradingview?sym="
    let symbol: String
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("did finish loading webview")
            parent.loadStatusChanged?(false, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("webview failed with error: \(error.localizedDescription)")
            parent.loadStatusChanged?(false, error)
        }
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = context.coordinator
                
        return webView
    
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let urlString = baseUrl + symbol
        print("trading view url = \(urlString)")
        if let requestUrl = URL(string: urlString) {
            webView.load(URLRequest(url: requestUrl))
        }
    }
}
