//
// WebViewController.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import WebKit

extension WKWebView {
    convenience init(navigationDelegate: WKNavigationDelegate) {
        self.init()
        self.navigationDelegate = navigationDelegate
    }
    
    func loadURL(_ URL: Foundation.URL) {
        load(URLRequest(url: URL))
    }
}

protocol WebViewControllerDelegate: class {
    func shouldHandleURL(_ URL: URL) -> Bool
    func handleURL(_ URL: URL)
    func webViewControllerDidFinish(_ controller: WebViewController)
}

internal class WebViewController: UINavigationController {
    init(URL: Foundation.URL, delegate: WebViewControllerDelegate) {
        super.init(rootViewController: ViewController(URL: URL, delegate: delegate))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ViewController: UIViewController {
    let URL: Foundation.URL
    unowned let delegate: WebViewControllerDelegate
    
    init(URL: Foundation.URL, delegate: WebViewControllerDelegate) {
        self.URL = URL
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = WKWebView(navigationDelegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        
        if let view = view as? WKWebView {
            view.loadURL(URL)
        }
    }
    
    @objc func cancel(_ item: UIBarButtonItem) {
        if let controller = navigationController as? WebViewController {
            delegate.webViewControllerDidFinish(controller)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let URL = navigationAction.request.url , delegate.shouldHandleURL(URL) else {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
        delegate.handleURL(URL)
    }
}
