// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@available(iOS 13.0, *)
class OverlayFlutterViewController: FlutterViewController, FlutterStreamHandler {
    var firstPageVC = UIViewController()
    var secondPageVC = UIViewController()
    var pageNC = UINavigationController()
    
    var screenWidth: CGFloat = 0
    var screenRefreshRate: Int = 60
    
    var timer: Timer?
    var startTime: CFTimeInterval = 0.0
    var endTime: CFTimeInterval = 0.0
    var hasTransitionStarted: Bool = false

    var eventSink: FlutterEventSink?
    lazy var eventChannel: FlutterEventChannel =
        .init(name: "overlay_ios.flutter.io/responder",
              binaryMessenger: self as! FlutterBinaryMessenger)
    
    lazy var methodChannel: FlutterMethodChannel = .init(name: "overlay_ios.flutter.io/sender", binaryMessenger: self as! FlutterBinaryMessenger)
    
    // MARK: App cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = pageNC.view.bounds.size.width
        screenRefreshRate = view.window?.windowScene?.screen.maximumFramesPerSecond ?? 60
        
        pageNC = UINavigationController(rootViewController: firstPageVC)
        pageNC.setNavigationBarHidden(true, animated: true)
        
        methodChannel.setMethodCallHandler { [self]
            (call: FlutterMethodCall, _: @escaping FlutterResult) in
                if call.method == "push" {
                    secondPageVC = UIViewController()
                    secondPageVC.view.backgroundColor = .systemBlue
                    pageNC.pushViewController(secondPageVC, animated: true)
                    
                    startTime = CACurrentMediaTime()
                    hasTransitionStarted = true
                    eventSink!("transition start")
                    
                    setupTransitionReporting(hz: screenRefreshRate)
                } else if call.method == "pop" {
                    pageNC.popViewController(animated: true)
                    
                    startTime = CACurrentMediaTime()
                    hasTransitionStarted = true
                    eventSink!("transition start")
                    
                    setupTransitionReporting(hz: screenRefreshRate)
                } else if call.method == "slow-mo enabled" {
                    pageNC.view.layer.speed = 0.2
                } else if call.method == "slow-mo disabled" {
                    pageNC.view.layer.speed = 1.0
                }
        }
        
        DispatchQueue.main.async {
            self.eventChannel.setStreamHandler(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addChild(pageNC)
        pageNC.view.frame = view.bounds
        pageNC.didMove(toParent: self)
        view.addSubview(pageNC.view)
        pageNC.view.backgroundColor = .white
        pageNC.view.center.y += CGFloat(firstPageVC.view.frame.midY)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        label.frame.origin.y = view.center.y / 2
        label.center.x = firstPageVC.view.center.x
        label.textAlignment = .center
        label.text = "Native iOS"
        label.textColor = .black
        firstPageVC.view.addSubview(label)
        
        pageNC.view.addSubview(firstPageVC.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset view upon disappearance
        view.subviews.forEach { $0.removeFromSuperview() }
        children.forEach { $0.removeFromParent() }
        timer?.invalidate()
    }
    
    // MARK: Flutter Stream Handler

    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError?
    {
        print(events)
        eventSink = events
        
        eventSink!("maximum refresh rate: \(screenRefreshRate)")
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        nil
    }
    
    func getControllersRelativePosition(_ a: UIViewController, _ b: UIViewController) -> CGFloat {
        let aFrame = a.view.layer.presentation()?.frame ?? CGRect.zero
        let bLayer = b.view.layer
        let convertedRect = a.view.layer.presentation()?.convert(aFrame, to: bLayer)
        
        return convertedRect?.origin.x ?? 0.0
    }
    
    func setupTransitionReporting(hz: Int) {
        let frameTime = Double(1 / Double(hz))
        
        timer = Timer.scheduledTimer(withTimeInterval: frameTime, repeats: true) { [self] _ in
            let currPosition = getControllersRelativePosition(secondPageVC, pageNC)
            let delta = (screenWidth - currPosition) / screenWidth
            
            endTime = CACurrentMediaTime()
            let timeDelta = endTime - startTime
            
            if hasTransitionStarted {
                eventSink!(delta)
            }
            
            if delta == 1.0 && hasTransitionStarted && timeDelta > 0.05 {
                eventSink!("iOS transition took approx: \(timeDelta)")
                print("iOS transition took approx: \(timeDelta)")
                
                hasTransitionStarted = false
                eventSink!("transition stop")
                timer?.invalidate()
            }
        }
    }
}
