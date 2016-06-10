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
    
    func loadURL(URL: NSURL) {
        loadRequest(NSURLRequest(URL: URL))
    }
}

protocol WebViewControllerDelegate: class {
    func shouldHandleURL(URL: NSURL) -> Bool
    func handleURL(URL: NSURL)
    func webViewControllerDidFinish(controller: WebViewController)
}

internal class WebViewController: UINavigationController {
    init(URL: NSURL, delegate: WebViewControllerDelegate) {
        super.init(rootViewController: ViewController(URL: URL, delegate: delegate))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ViewController: UIViewController {
    let URL: NSURL
    unowned let delegate: WebViewControllerDelegate
    
    init(URL: NSURL, delegate: WebViewControllerDelegate) {
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ViewController.cancel))
        
        if let view = view as? WKWebView {
            view.loadURL(URL)
        }
    }
    
    @objc func cancel(item: UIBarButtonItem) {
        if let controller = navigationController as? WebViewController {
            delegate.webViewControllerDidFinish(controller)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    @objc func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let URL = navigationAction.request.URL where delegate.shouldHandleURL(URL) else {
            decisionHandler(.Allow)
            return
        }
        
        decisionHandler(.Cancel)
        delegate.handleURL(URL)
    }
}