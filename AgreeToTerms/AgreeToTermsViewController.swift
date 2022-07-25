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
import Combine

class AgreeToTermsViewController: UIViewController {
    
    private var webView: WKWebView!
    private var finishedLoad: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    private var policyModel = PolicySignModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissController))
                
        setupWebView()
        
        setupButtons()
    }
    
    private func setupButtons() {
        
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        guard let webView = webView,
              let url = URL (string: policyModel.currentURL())
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
        let decision: WKNavigationActionPolicy = policyModel.shouldAllowPage(absoluteString: navigationAction.request.url?.absoluteString ?? "")
        decisionHandler(decision)
    }
    
}

extension AgreeToTermsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard finishedLoad else {
            return
        }
        
        policyModel.updateModelWithScroll(contentSizeHeight: scrollView.contentSize.height, scrollViewHeightBound: scrollView.bounds.height, contentOffsetY: scrollView.contentOffset.y)
    }
}
