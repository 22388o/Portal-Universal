//
//  WebViewRepresentable.swift
//  Portal (iOS)
//
//  Created by Farid on 28.09.2021.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    private let baseUrl: String = "https://cryptomarket-api.herokuapp.com/exchange/tradingview?sym="
    let symbol: String
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.allowsBackForwardNavigationGestures = true
        return webView
    
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let urlString = baseUrl + symbol
        print("trading view url = \(urlString)")
        if let requestUrl = URL(string: urlString) {
            webView.load(URLRequest(url: requestUrl))
        }
    }
}
