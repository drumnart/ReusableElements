//
//  WebViewController.swift
//
//  Created by Sergey Gorin on 18/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    fileprivate enum KVOKeys: String {
        case estimatedProgress
        case loading
    }
    
    var progressHeight: CGFloat = 2.0
    var progressTintColor: UIColor = .blue {
        didSet {
            progressView.progressTintColor = progressTintColor
        }
    }
    var trackTintColor: UIColor = .white {
        didSet {
            progressView.trackTintColor = trackTintColor
        }
    }
    
    var hidesNavigationBarOnScroll = true
    var hidesStatusBarOnScroll = true
    var statusbarStyle: () -> UIStatusBarStyle = { .default }
    var statusBarUpdateAnimation: () -> UIStatusBarAnimation = { .slide }
    
    var setPullToRefreshEnabled: Bool = true {
        didSet {
            if setPullToRefreshEnabled == true {
                webView.scrollView.xt.onPullToRefresh { [unowned self] sender in
                    self.webView.reload()
                }
            } else {
                webView.scrollView.xt.removeRefreshControl()
            }
        }
    }
    
    var canGoBack: Bool = true
    var enablesDoneButton: Bool = false
    
    private(set) var url: URL?
    private(set) var urlRequest: URLRequest?
    private(set) var htmlString: String?
    
    private var statusBarShouldBeHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    private(set) lazy var preferences: WKPreferences = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        return preferences
    }()
    
    private(set) lazy var configuration: WKWebViewConfiguration = {
        let configuration  = WKWebViewConfiguration()
        configuration.preferences = self.preferences
        
        return configuration
    }()
    
    var rightBarSystemItem: UIBarButtonItem.SystemItem = .done
    
    var webView: WKWebView!
    var progressView: ProgressView!
    var backButton: UIBarButtonItem!
    var rightBarButton: UIBarButtonItem!
    
    private var didSetProgressObserver = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(urlString: String) {
        self.init(url: URL(string: urlString)!)
    }
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        self.url = urlRequest.url
        super.init(nibName: nil, bundle: nil)
    }
    
    init(url: URL) {
        self.urlRequest = URLRequest(url: url)
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    init(htmlString: String) {
        self.htmlString = htmlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.url = URL(string: "")
        super.init(coder: aDecoder)
    }
    
    deinit {
        if didSetProgressObserver {
            webView?.removeObserver(self, forKeyPath: KVOKeys.loading.rawValue)
            webView?.removeObserver(self, forKeyPath: KVOKeys.estimatedProgress.rawValue)
        }
    }
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusbarStyle()
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarUpdateAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.navigationBar.enableVisualEffect()
        
        progressView = ProgressView(progressViewStyle: .bar).with {
            $0.frame = CGRect(x: 0, y: safeAreaTopInset,
                              width: view.bounds.width, height: progressHeight)
            
            $0.progressTintColor = self.progressTintColor
            $0.trackTintColor = self.trackTintColor
            
            view.addSubview($0)
            
            $0.xt.applyConstraints {
                [
                    $0.topAnchor.constraint(equalTo: safeAreaTopAnchor),
                    $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    $0.widthAnchor.constraint(equalTo: view.widthAnchor),
                    $0.heightAnchor.constraint(equalToConstant: progressHeight)
                ]
            }
            
            didSetProgressObserver = true
        }
        
        webView = WKWebView(frame: view.bounds, configuration: configuration).with {
            $0.navigationDelegate = self
            $0.scrollView.delegate = self
            $0.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
            $0.allowsBackForwardNavigationGestures = true
            $0.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
            $0.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            
            if setPullToRefreshEnabled {
                $0.scrollView.xt.onPullToRefresh { [unowned self] sender in
                    self.webView.reload()
                }
            }
            view.insertSubview($0, belowSubview: progressView)
            
            $0.xt.applyConstraints {
                [
                    $0.topAnchor.constraint(equalTo: safeAreaTopAnchor),
                    $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    $0.bottomAnchor.constraint(equalTo: safeAreaBottomAnchor)
                ]
            }
        }
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNavigationItems()
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        navigationController?.navigationBar.visualEffectSubview?.fadeIn()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.navigationBar.disableTransparency()
//        navigationController?.navigationBar.disableVisualEffect()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        statusBarShouldBeHidden = UIDevice.current.orientation.isLandscape
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        switch KVOKeys(rawValue: keyPath ?? "") {
        case .some(.estimatedProgress):
            if let progress = webView?.estimatedProgress {
                progressView.setProgress(Float(progress), animated: true)
                if progress == 1.0 {
                    hideProgress() {
                        self.progressView.setProgress(0.0, animated: false)
                    }
                }
            }
            
        case .some(.loading):
            if isModal {
                backButton?.isEnabled = webView.canGoBack
            }
            
        default: break
        }
    }
    
    private func addNavigationItems() {
        if canGoBack {
            backButton = UIBarButtonItem(image: Asset.Arrows.backArrow.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(back))
            navigationItem.leftBarButtonItems = [backButton]
        }
        
        if isModal && enablesDoneButton {
            rightBarButton = UIBarButtonItem(barButtonSystemItem: rightBarSystemItem,
                                             target: self, action: #selector(done))
            navigationItem.setRightBarButtonItems([rightBarButton], animated: false)
        }
    }
    
    @objc func back() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func done() {
        dismiss(animated: true) {}
    }
    
    fileprivate func setBarsHidden(_ hidden: Bool, withDuration duration: Double = 0.3) {
        UIView.animate(withDuration: duration) {
            self.navigationController?.setNavigationBarHidden(hidden, animated: false)
        }
    }
    
    func load() {
        if let request = urlRequest {
            webView.load(request)
        } else if let url = url {
            webView.load(URLRequest(url: url))
        } else if let htmlString = htmlString {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.xt.endRefreshing()
        progressView.setProgress(1.0, animated: true)
        hideProgress() {
            self.progressView.setProgress(0.0, animated: false)
        }
    }
    
    fileprivate func hideProgress(after delay: DispatchTimeInterval = .seconds(1), completion: @escaping () -> Void = {}) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.progressView.isHidden = true
            completion()
        }
    }
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if hidesStatusBarOnScroll { statusBarShouldBeHidden = velocity.y > 0 }
        if hidesNavigationBarOnScroll { setBarsHidden(velocity.y > 0) }
    }
}

