//
//  AgreeToTermsViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//


/**
    Navigation Bar
    Combine + Modeling
    Swift ui
 
 */

import WebKit

class AgreeToTermsViewController: UIViewController {
    
    var webView: WKWebView!
    var finishedLoad: Bool = false
    var canMoveToNextPage: Bool = false
    
    let eulaURLString = "https://www.viz.ai/eula"
    let privacyURLString = "https://www.viz.ai/privacy-policy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissController))
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        guard let webView = webView,
              let url = URL (string: eulaURLString)
        else {
            return
        }
        
        let requestObj = URLRequest(url: url)
        webView.load(requestObj)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
        
    @objc func dismissController() {
        self.navigationController?.dismiss(animated: true) {
            // TODO: Tracking
        }
    }
}

extension AgreeToTermsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishedLoad = true
    }
    
    /* Allow to load accept policy only URL */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if url == eulaURLString || url == privacyURLString {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }
    }
    
}

extension AgreeToTermsViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard finishedLoad else {
            return
        }
        
        let maxY = scrollView.contentSize.height - scrollView.bounds.height
        let yPosition = scrollView.contentOffset.y
        let delta = maxY-yPosition
        
        if delta < 0 {
            canMoveToNextPage = true
            // TODO: Tracking?
        }
    }
}
