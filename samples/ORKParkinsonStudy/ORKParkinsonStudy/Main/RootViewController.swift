/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import UIKit

class RootViewController: UIViewController, OnboardingManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OnboardingStateManager.shared.getOnboardingCompletedState() == false {
            let onboardingViewController = OnboardingViewController(task: nil, taskRun: nil)
            onboardingViewController.onboardingManagerDelegate = self
            
            self.present(onboardingViewController, animated: false, completion: nil)
        } else {
            self.didCompleteOnboarding()
        }
    }
    
    func didCompleteOnboarding() {
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let taskListViewController = TaskListViewController()
        let taskListNavController = UINavigationController(rootViewController: taskListViewController)
        taskListNavController.navigationBar.shadowImage = UIImage()
        taskListNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        taskListNavController.tabBarItem.title = NSLocalizedString("Tasks", comment: "")
        taskListNavController.tabBarItem.image = UIImage(named: "surveyTab")
        taskListNavController.navigationBar.titleTextAttributes = textAttributes
        
        let graphViewController = GraphViewController(style: .grouped)
        graphViewController.title = "Graphs"
        let graphNavigationController = UINavigationController(rootViewController: graphViewController)
        
        graphNavigationController.view.backgroundColor = Colors.tableViewBackgroundColor.color
        graphNavigationController.navigationBar.prefersLargeTitles = true
        graphNavigationController.navigationBar.barTintColor = Colors.appTintColor.color
        graphNavigationController.tabBarItem.title = NSLocalizedString("Graphs", comment: "")
        graphNavigationController.tabBarItem.image = UIImage(named: "graphTab")
        graphNavigationController.navigationBar.titleTextAttributes = textAttributes
        graphNavigationController.navigationBar.largeTitleTextAttributes = textAttributes
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [taskListNavController, graphNavigationController]
        tabBarController.tabBar.barTintColor = Colors.tableViewCellBackgroundColor.color
        tabBarController.tabBar.tintColor = Colors.dyskinesiaSymptomGraphColor.color
        self.present(tabBarController, animated: true, completion: nil)
    }
}

public extension UIImage {
    public convenience init?(color: UIColor) {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}


