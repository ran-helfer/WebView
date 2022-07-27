//
//  PolicyAgreementViewModel.swift
//  AgreeToTerms
//
//  Created by Ran Helfer on 25/07/2022.
//

import UIKit
import Combine

/*
 COMMENTS:
 - created a protocol for the public view model API
 - instead of exposing a `CurrentValueSubject` (which lets anyone publish events), use a Publisher, which only lets observing
 - instead of returning a `WKNavigationActionPolicy` just return a `bool`
 */

protocol PolicyAgreementViewModelProtocol {
    var canMoveToNextPage: AnyPublisher<Bool, Never> { get }
    var currentPage: AnyPublisher<Int, Never> { get }
    var policySignEnded: AnyPublisher<Bool, Never> { get }

    func currentURL() -> String
    func approveButtonPressed()
    func shouldAllowPage(absoluteString: String?) -> Bool
    func updateModelWithScroll(contentSizeHeight: CGFloat, scrollViewHeightBound: CGFloat, contentOffsetY: CGFloat)
}

final class PolicyAgreementViewModel: PolicyAgreementViewModelProtocol {
    private let urlForPage = ["https://www.viz.ai/eula",
                              "https://www.viz.ai/privacy-policy"]

    let canMoveToNextPage: AnyPublisher<Bool, Never>
    let currentPage: AnyPublisher<Int, Never>
    let policySignEnded: AnyPublisher<Bool, Never>

    private let canMoveToNextPageSubject = CurrentValueSubject<Bool, Never>(false)
    private let currentPageSubject = CurrentValueSubject<Int, Never>(0)
    private let policySignEndedSubject = CurrentValueSubject<Bool, Never>(false)

    init() {
        self.canMoveToNextPage = canMoveToNextPageSubject.eraseToAnyPublisher()
        self.currentPage = currentPageSubject.eraseToAnyPublisher()
        self.policySignEnded = policySignEndedSubject.eraseToAnyPublisher()
    }

    func currentURL() -> String {
        return urlForPage[currentPageSubject.value]
    }

    func approveButtonPressed() {
        if currentPageSubject.value == urlForPage.count - 1 {
            policySignCompleted()
            return
        }

        currentPageSubject.send(currentPageSubject.value + 1)
        canMoveToNextPageSubject.send(false)
    }

    private func policySignCompleted() {
        policySignEndedSubject.send(true)

        // Write to userDefults
        // Send policy sign completed to backend

    }

    func shouldAllowPage(absoluteString: String?) -> Bool {
        guard let absoluteString = absoluteString else { return false }
        return urlForPage.contains(absoluteString)
    }

    func updateModelWithScroll(contentSizeHeight: CGFloat, scrollViewHeightBound: CGFloat, contentOffsetY: CGFloat ) {

        let delta = contentSizeHeight - scrollViewHeightBound - contentOffsetY

        if delta < 0 {
            canMoveToNextPageSubject.send(true)
            // TODO: Tracking?
        }
    }

}
