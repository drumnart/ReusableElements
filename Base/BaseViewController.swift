//
//  BaseViewController.swift
//
//  Created by Sergey Gorin on 07/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

typealias BaseVC = BaseViewController

class BaseViewController<View: UIView>: UIViewController {
    
    func view() -> View {
        return view as? View ?? View()
    }
    
    var _view: View {
        return view()
    }
    
    override func loadView() {
        view = View()
    }
}
