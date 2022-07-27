//
//  AgreeToTermsViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//


/**
    Swift UI ?
 */

import WebKit
import Combine

/*
 COMMENTS:
 - renamed to match feature and make it consistent with view model
 - provided constructor to inject view model from outside
 - renamed `subscriptions` to `cancellables` which is sort the naming rule
 - substituted the mutable force-uncast view attributes with non-mutable instantiated objects
 */

final class PolicyAgreementViewController: UIViewController {
        
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let buttonsStackView = UIStackView(frame: .zero)
    private let approveButton = buttonWithText(text: "Approve")
    private let declineButton = buttonWithText(text: "Decline")
    
    private var finishedLoad: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: PolicyAgreementViewModelProtocol

    init(viewModel: PolicyAgreementViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        
        setupSubscriptions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static private func buttonWithText(text: String) -> UIButton {
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
        let stack = self.buttonsStackView
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.backgroundColor = .gray
        stack.spacing = 20

        declineButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        approveButton.addTarget(self, action: #selector(approveButtonTouch), for: .touchUpInside)
        approveButton.isEnabled = false
        
        stack.addArrangedSubview(declineButton)
        stack.addArrangedSubview(approveButton)

        view.addSubview(stack)
        stack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @objc func approveButtonTouch() {
        viewModel.approveButtonPressed()
    }
    
    private func setupWebView() {
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
        viewModel.canMoveToNextPage.sink { [weak self] val in
            guard let self = self else {return}
            self.approveButton.isEnabled  = val
        }.store(in: &cancellables)
        
        viewModel.currentPage.sink { [weak self] val in
            guard let self = self,
                  let url = URL (string: self.viewModel.currentURL()) else {
                return
            }
            self.finishedLoad = false
            let requestObj = URLRequest(url: url)
            self.webView.load(requestObj)
        }.store(in: &cancellables)
        
        viewModel.policySignEnded.sink { [weak self] val in
            if val {
                self?.dismissController()
            }
        }.store(in: &cancellables)
    }
    
    @objc func dismissController() {
        self.navigationController?.dismiss(animated: true) {
            // TODO: Tracking
        }
    }
}

extension PolicyAgreementViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishedLoad = true
    }
    
    /* Allow to load accept policy only URL */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let allowed = viewModel.shouldAllowPage(absoluteString: navigationAction.request.url?.absoluteString)
        decisionHandler(allowed ? .allow : .cancel)
    }
    
}

extension PolicyAgreementViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard finishedLoad else {
            return
        }
        
        viewModel.updateModelWithScroll(contentSizeHeight: scrollView.contentSize.height, scrollViewHeightBound: scrollView.bounds.height, contentOffsetY: scrollView.contentOffset.y)
    }
}
