//
//  Shareable.swift
//
//  Created by Sergey Gorin on 15/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol Shareable {
    
    func share(activityItems items: [Any],
               appActivities: [UIActivity]?,
               excluding: [UIActivity.ActivityType]?,
               in controller: UIViewController,
               completion: UIActivityViewController.CompletionWithItemsHandler?)
}

extension Shareable {
    
    func share(activityItems items: [Any],
               appActivities: [UIActivity]? = nil,
               excluding: [UIActivity.ActivityType]? = [UIActivity.ActivityType.airDrop,
                                                        UIActivity.ActivityType.addToReadingList],
               in controller: UIViewController,
               completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: appActivities)
        activityVC.completionWithItemsHandler = completion
        
        //New Excluded Activities
        activityVC.excludedActivityTypes = excluding
        
        controller.present(activityVC, animated: true, completion: nil)
    }
}
