//
//  AgreeToTermsViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//


/**
    Combine + Modeling
    Swift ui
 
 */

import WebKit
import Combine

class AgreeToTermsViewController: UIViewController {
        
    private var webView: WKWebView!
    private var buttonsStackView: UIStackView!
    private var finishedLoad: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    private var policyModel = PolicySignModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissController))
        
        // https://stackoverflow.com/a/69135729/4853489
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        self.view.backgroundColor = .white
        
        setupButtons()
        
        setupWebView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func buttonWithText(text: String) -> UIButton {
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 50)))
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 2
        btn.setTitle(text, for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.setTitleColor(.systemGray, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return btn
    }
    
    private func setupButtons() {
        let stack =  UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.backgroundColor = .gray
        stack.spacing = 20

        let declineButton = buttonWithText(text: "Decline")
        declineButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        let approveButton = buttonWithText(text: "Approve")
        declineButton.addTarget(self, action: #selector(approveButtonTouch), for: .touchUpInside)
        approveButton.isEnabled = false
        
        stack.addArrangedSubview(declineButton)
        stack.addArrangedSubview(approveButton)

        view.addSubview(stack)
        stack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        self.buttonsStackView = stack
    }

    @objc func approveButtonTouch() {
        // update model
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
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.load(requestObj)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor).isActive = true
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
        let decision: WKNavigationActionPolicy = policyModel.shouldAllowPage(absoluteString: navigationAction.request.url?.absoluteString)
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
