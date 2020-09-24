//
//  Storyboard+Extension.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	
import UIKit

extension UIStoryboard {
    enum StoryBoard: String {
        case main
        var name: String {
            rawValue.capitalizingFirstLetter()
        }
    }
    
    convenience init(storyboard: StoryBoard, bundle: Bundle? = nil) {
        self.init(name: storyboard.name, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }

        return viewController
    }
}

extension UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
