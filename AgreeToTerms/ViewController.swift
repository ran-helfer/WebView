//
//  ViewController.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 24/07/2022.
//

import WebKit

/*
    Initial view controller showing a single button "Accept Terms" imitiating:
        https://www.figma.com/file/SZAfVh4PyvWfGa7A281aan/EULA-page-and-confirmation-(DEV)?node-id=101%3A3514
 */

class ViewController: UIViewController {

    var webView: WKWebView?
    
    @IBAction func acceptTermsClicked(_ sender: Any) {
        let controller = AgreeToTermsViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true)
    }
}
