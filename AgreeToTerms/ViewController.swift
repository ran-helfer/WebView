//
//  ViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//

import WebKit

class ViewController: UIViewController {

    var webView: WKWebView?
    
    @IBAction func acceptTermsClicked(_ sender: Any) {
        let viewModel = PolicyAgreementViewModel()
        let controller = PolicyAgreementViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true)
    }
}
