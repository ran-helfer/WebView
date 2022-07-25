//
//  PolicySignModel.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 25/07/2022.
//

import Foundation
import WebKit
import Combine

final class PolicySignModel {
    private let urlForPage = ["https://www.viz.ai/eula",
                              "https://www.viz.ai/privacy-policy"]
    var canMoveToNextPage = CurrentValueSubject<Bool, Never>(false)
    var currentPage = CurrentValueSubject<Int, Never>(0)
    var policySignEnded = CurrentValueSubject<Bool, Never>(false)

    func currentURL() -> String {
        return urlForPage[currentPage.value]
    }
    
    func approveButtonPressed() {
        if currentPage.value == urlForPage.count - 1 {
            policySignCompleted()
            return
        }
        currentPage.value += 1
        canMoveToNextPage.value = false
    }
    
    private func policySignCompleted() {
        policySignEnded.value = true
        
        // Write to userDefults
        // Send policy sign completed to backend
        
    }
    
    func shouldAllowPage(absoluteString: String?) -> WKNavigationActionPolicy {
        guard let  absoluteString = absoluteString else {
            return .cancel
        }
        
        if urlForPage.contains(absoluteString) {
            return WKNavigationActionPolicy.allow
        }
        
        return WKNavigationActionPolicy.cancel
    }
    
    func updateModelWithScroll(contentSizeHeight: CGFloat, scrollViewHeightBound: CGFloat, contentOffsetY: CGFloat ) {

        let delta = contentSizeHeight - scrollViewHeightBound - contentOffsetY
        
        if delta < 0 {
            canMoveToNextPage.value = true
            // TODO: Tracking?
        }
    }
    
}
