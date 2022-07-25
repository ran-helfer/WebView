//
//  PolicySignModel.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 25/07/2022.
//

import Foundation
import WebKit

final class PolicySignModel {
    private var currentPage = 0
    private let urlForPage = ["https://www.viz.ai/eula",
                              "https://www.viz.ai/privacy-policy"]
    private var canMoveToNextPage: Bool = false


    func currentURL() -> String {
        return urlForPage[currentPage]
    }
    
    func shouldAllowPage(absoluteString: String) -> WKNavigationActionPolicy {
        if urlForPage.contains(absoluteString) {
            return WKNavigationActionPolicy.allow
        }
        return WKNavigationActionPolicy.cancel
    }
    
    func updateModelWithScroll(contentSizeHeight: CGFloat, scrollViewHeightBound: CGFloat, contentOffsetY: CGFloat ) {

        let delta = contentSizeHeight - scrollViewHeightBound - contentOffsetY
        
        if delta < 0 {
            canMoveToNextPage = true
            // TODO: Tracking?
        }
    }
    
}
