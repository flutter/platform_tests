import UIKit
import Flutter
import Foundation

class PageViewOverlayViewController : FlutterViewController {
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(engine: FlutterEngine) {
        super.init(engine: engine, nibName: nil, bundle: nil)
    }
    
    let pageViewController = PageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(pageViewController)
        pageViewController.view.frame = view.bounds
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.addGestureRecognizer(PassThroughGestureRecognizer(self))
    }
}

class TabViewController : UIViewController {
    var index: Int = 0
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.magenta
        view.addSubview(label)
        label.text = "iOS tab \(index + 1)"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = label.font.withSize(16)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = 130.0
        view.frame = CGRect(
            x: 0,
            y: topInset,
            width: UIScreen.main.bounds.size.width,
            height: (UIScreen.main.bounds.size.height - topInset) / 2.0
        )

        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(
                item: label,
                attribute: NSLayoutConstraint.Attribute.bottom,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.bottom,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: label,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.width,
                multiplier: 1,
                constant: 0),
        ])
    }
}

class PageViewController : UIPageViewController, UIPageViewControllerDataSource {
    required init(coder: NSCoder? = nil) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: UIPageViewController.NavigationOrientation.horizontal,
            options: nil)
    }
    
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        view.alpha = 0.5
        view.backgroundColor = UIColor.clear
        pages.append(TabViewController())
        pages.append(TabViewController())
        for (index, page) in pages.enumerated() {
            (page as! TabViewController).index = index
        }
        
        setViewControllers([pages[0]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    func pageViewController(_: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard pages.count > previousIndex else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let pagesCount = pages.count
        guard pagesCount != nextIndex else {
            return nil
        }
        guard pagesCount > nextIndex else {
            return nil
        }
        return pages[nextIndex]
    }
}

class PassThroughGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    let eventForwardingTarget: UIResponder
    init(_ controller: FlutterViewController) {
        eventForwardingTarget = controller.view
        super.init(target: nil, action: nil)
        delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        eventForwardingTarget.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        eventForwardingTarget.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        eventForwardingTarget.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        eventForwardingTarget.touchesCancelled(touches, with: event)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
