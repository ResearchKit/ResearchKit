/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties

    var window: UIWindow?
    
    var tabBarController: UITabBarController {
        return window!.rootViewController as! UITabBarController
    }
    
    var taskListViewController: TaskListViewController {
        let navigationController = tabBarController.viewControllers!.first as! UINavigationController

        return navigationController.visibleViewController as! TaskListViewController
    }
    
    var resultViewController: ResultViewController? {
        let navigationController = tabBarController.viewControllers![1] as! UINavigationController

        // Find the `ResultViewController` (if any) that's a view controller in the navigation controller.
        return navigationController.viewControllers.filter { $0 is ResultViewController }.first as? ResultViewController
    }
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // When a task result has been finished, update the result view controller's task result.
        taskListViewController.taskResultFinishedCompletionHandler = { [unowned self] taskResult in
            /*
                If we're displaying a new result, make sure the result view controller's
                navigation controller is at the root.
            */
            if let navigationController = self.resultViewController?.navigationController {
                navigationController.popToRootViewController(animated: false)
            }
            
            // Set the result so we can display it.
            self.resultViewController?.result = taskResult
        }
        
        return true
    }
}
