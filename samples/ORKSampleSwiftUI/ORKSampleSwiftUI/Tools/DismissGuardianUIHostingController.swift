//
//  DisableDismissUIHostingController.swift
//  ORKSampleSwiftUI
//
//  Created by Helio Tejedor on 10/26/20.
//

import UIKit
import SwiftUI

class DisableDismissUIHostingController<Content: View>: UIHostingController<Content>, UIAdaptivePresentationControllerDelegate {
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.presentationController?.delegate = self
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
