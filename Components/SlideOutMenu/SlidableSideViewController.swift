//
//  SlidableSideViewController.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SlidableSideViewController: UIViewController {
    
    var edge: SlideOutMenu.Edge = .left
    var contentVisibleRate: CGFloat = 0.9
    
    var contentView: UIView!
    var restAreaView: UIView! // It's for dismiss gestures
    
    var canvasColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = canvasColor
        
        contentView = UIView().with {
            $0.clipsToBounds = true
            view.addSubview($0)
            
            $0.xt.applyConstraints {
                switch edge {
                case .top: return
                    [
                        $0.leftAnchor.constraint(equalTo: view.leftAnchor),
                        $0.rightAnchor.constraint(equalTo: view.rightAnchor),
                        $0.topAnchor.constraint(equalTo: view.topAnchor),
                        $0.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                   multiplier: contentVisibleRate)
                    ]
                case .left: return
                    [
                        $0.topAnchor.constraint(equalTo: view.topAnchor),
                        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        $0.leftAnchor.constraint(equalTo: view.leftAnchor),
                        $0.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                  multiplier: contentVisibleRate)
                    ]
                case .bottom: return
                    [
                        $0.leftAnchor.constraint(equalTo: view.leftAnchor),
                        $0.rightAnchor.constraint(equalTo: view.rightAnchor),
                        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        $0.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                   multiplier: contentVisibleRate)
                    ]
                case .right: return
                    [
                        $0.topAnchor.constraint(equalTo: view.topAnchor),
                        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        $0.rightAnchor.constraint(equalTo: view.rightAnchor),
                        $0.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                  multiplier: contentVisibleRate)
                    ]
                }
            }
        }
        
        restAreaView = UIView().with {
            view.addSubview($0)
            
            switch edge {
            case .top:
                $0.xt.activate(constraints: [
                    $0.leftAnchor.constraint(equalTo: view.leftAnchor),
                    $0.rightAnchor.constraint(equalTo: view.rightAnchor),
                    $0.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                    $0.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
                )
                
            case .left:
                $0.xt.activate(constraints: [
                    $0.topAnchor.constraint(equalTo: view.topAnchor),
                    $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    $0.leftAnchor.constraint(equalTo: contentView.rightAnchor),
                    $0.rightAnchor.constraint(equalTo: view.rightAnchor)]
                )
                
            case .bottom:
                $0.xt.activate(constraints: [
                    $0.leftAnchor.constraint(equalTo: view.leftAnchor),
                    $0.rightAnchor.constraint(equalTo: view.rightAnchor),
                    $0.bottomAnchor.constraint(equalTo: contentView.topAnchor),
                    $0.topAnchor.constraint(equalTo: view.topAnchor)]
                )
                
            case .right:
                $0.xt.activate(constraints: [
                    $0.topAnchor.constraint(equalTo: view.topAnchor),
                    $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    $0.rightAnchor.constraint(equalTo: contentView.leftAnchor),
                    $0.leftAnchor.constraint(equalTo: view.leftAnchor)]
                )
            }
        }
    }
}
