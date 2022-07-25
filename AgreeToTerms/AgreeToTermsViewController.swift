//
//  AgreeToTermsViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//


/**
    Swift UI ?
 */

/**
    Agree to terms view controller is attached to PolicySignModel using combine framework. Only when user is scrolling to the end he is allowed to go to next page.
 */

import WebKit
import Combine

class AgreeToTermsViewController: UIViewController {
        
    private var webView: WKWebView!
    private var buttonsStackView: UIStackView!
    private var approveButton: UIButton!
    private var declineButton: UIButton!

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
        
        self.view.backgroundColor = .black
        
        setupButtons()
        
        setupWebView()
        
        setupSubscriptions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func buttonWithText(text: String) -> UIButton {
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 167, height: 50)))
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.setTitle(text, for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.titleLabel?.font = UIFont(name: "SF Pro", size: 17.0)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.isEnabled = false
        return btn
    }
    
    private func setupButtons() {
        let stack =  UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.backgroundColor = .black
        stack.spacing = 16

        let declineButton = buttonWithText(text: "Decline")
        declineButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        let approveButton = buttonWithText(text: "Approve")
        approveButton.addTarget(self, action: #selector(approveButtonTouch), for: .touchUpInside)
        approveButton.backgroundColor = .systemBlue
        
        stack.addArrangedSubview(declineButton)
        stack.addArrangedSubview(approveButton)

        view.addSubview(stack)
        stack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.buttonsStackView = stack
        self.approveButton = approveButton
        self.declineButton = declineButton
    }

    @objc func approveButtonTouch() {
        policyModel.approveButtonPressed()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        guard let webView = webView else {
            return
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor).isActive = true
    }
    
    func setupSubscriptions() {
        policyModel.canMoveToNextPage.sink { [weak self] val in
            guard let self = self else {return}
            self.declineButton.isEnabled = val
            self.approveButton.isEnabled = val
        }.store(in: &subscriptions)
        
        policyModel.currentPage.sink { [weak self] val in
            guard let self = self,
                  let url = URL (string: self.policyModel.currentURL()) else {
                return
            }
            self.finishedLoad = false
            let requestObj = URLRequest(url: url)
            self.webView.load(requestObj)
        }.store(in: &subscriptions)
        
        policyModel.policySignEnded.sink { [weak self] val in
            if val {
                self?.dismissController()
            }
        }.store(in: &subscriptions)
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
