//
//  SceneDelegate.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let homeController = HomeController()
            let navController = CustomNavigationController(rootViewController: homeController)
            window.rootViewController = navController
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
}
