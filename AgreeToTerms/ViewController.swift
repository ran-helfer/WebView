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
        
        let controller = AgreeToTermsViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true)
    }
    
    
   
}



/**
 

 "https://www.viz.ai/eula"
 
"https://www.viz.ai/privacy-policy"
 
 
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

     CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];

     CGFloat height1 = scrollView.bounds.origin.y + self.webView.bounds.size.height;

     CGFloat height2 = fittingSize.height;

     int delta = fabs(height1 - height2);

     if (delta < 30) {

        NSLog(@"HELLO!!! You reached the page end!");
     }
     }
}
 
 
 */
