//
//  TabBarHelper.swift
//  DearDates
//

import UIKit

enum TabBarHelper {
    static func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        return findTabBarController(in: rootViewController)
    }

    private static func findTabBarController(in viewController: UIViewController) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        return nil
    }

    static func hideTabBar(animated: Bool = true) {
        guard let tabBarController = findTabBarController() else { return }
        if animated {
            UIView.animate(withDuration: 0.3) {
                tabBarController.tabBar.alpha = 0
                tabBarController.tabBar.isHidden = true
            }
        } else {
            tabBarController.tabBar.alpha = 0
            tabBarController.tabBar.isHidden = true
        }
    }

    static func showTabBar(animated: Bool = true) {
        guard let tabBarController = findTabBarController() else { return }
        tabBarController.tabBar.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.3) {
                tabBarController.tabBar.alpha = 1
            }
        } else {
            tabBarController.tabBar.alpha = 1
        }
    }
}
