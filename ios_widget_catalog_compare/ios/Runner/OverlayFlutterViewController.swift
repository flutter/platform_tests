import SwiftUI


/// The initial `UIViewController` defined in `Main.storyboard` uses this class.
/// It is overlayed on top of the Flutter controls that are defined in `../lib`
/// It will relay touch events to Flutter, so that the same touch event will reproduce
/// with both Flutter and Swift.

@available(iOS 14.0, *)
class OverlayFlutterViewController: FlutterViewController, FlutterStreamHandler, ObservableObject {
  
  // Widget catalogue
  @Published var controlKey: String = ""
    
  // SUI Overlay
  lazy var overlaySUIView: OverlaySwiftUIView = setOverlaySUIView()
  func setOverlaySUIView() -> OverlaySwiftUIView {
    OverlaySwiftUIView(controller: self)
  }
  var originalOverlayCenter: CGPoint = .zero
  
  lazy var suiController: UIViewController = setSUIController()
  func setSUIController() -> UIViewController {
    UIHostingController(rootView: OverlaySwiftUIView(controller: self))
  }

  // UI Controls
  var dropDownButton: UIButton = UIButton(frame: CGRect(x: 13, y: 50, width: 300, height: 40))

  var xSlider: UISlider = UISlider()
  var ySlider: UISlider = UISlider()
  var alphaSlider: UISlider = UISlider()
  
  lazy var slidersStackView: UIStackView = setSlidersStackView()
  func setSlidersStackView() -> UIStackView {
    UIStackView(arrangedSubviews: [xSlider, ySlider, alphaSlider])
  }
  
  // Flutter Stream Handler
  var eventSink: FlutterEventSink?
  
  lazy var eventChannel: FlutterEventChannel = setEventChannel()
  func setEventChannel() -> FlutterEventChannel {
    FlutterEventChannel(name: "overlay_ios.flutter.io/responder", binaryMessenger: self as! FlutterBinaryMessenger)
  }
  
  //MARK: App cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    xSlider.minimumValue = -200
    xSlider.maximumValue = 200
    xSlider.isContinuous = true
    xSlider.addTarget(self, action: #selector(xSliderChanged), for: .valueChanged)
    
    ySlider.minimumValue = -200
    ySlider.maximumValue = 200
    ySlider.isContinuous = true
    ySlider.addTarget(self, action: #selector(ySliderChanged), for: .valueChanged)
    
    alphaSlider.minimumValue = 0
    alphaSlider.maximumValue = 1
    alphaSlider.value = 1
    alphaSlider.isContinuous = true
    alphaSlider.addTarget(self, action: #selector(alphaSliderChanged), for: .valueChanged)
    
    slidersStackView.axis = .vertical
    slidersStackView.distribution = .equalSpacing
    slidersStackView.center = self.view.center
    slidersStackView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
    slidersStackView.isLayoutMarginsRelativeArrangement = true
    slidersStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
    slidersStackView.spacing = UIStackView.spacingUseSystem
    
    dropDownButton.setTitle("Select Control", for: .normal)
    dropDownButton.setTitleColor(.systemBlue, for: .normal)
    dropDownButton.contentHorizontalAlignment = .left
    dropDownButton.showsMenuAsPrimaryAction = true
    dropDownButton.menu =
      UIMenu(title: "",
             image: nil,
             identifier: nil,
             options: .displayInline,
             children: overlaySUIView.controlDictionary.map({ (key, arg2) -> UIAction in
              
              let (title, _) = arg2
              return UIAction(title: title, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { (action) in
                self.eventSink?(key)
                self.dropDownButton.setTitle(title, for: .normal)
                self.controlKey = key
              }
             })
      )
    
    DispatchQueue.main.async {
      self.eventChannel.setStreamHandler(self)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.addChild(suiController)
    suiController.view.frame = self.view.bounds
    originalOverlayCenter = suiController.view.center
    suiController.didMove(toParent: self)
    self.view.addSubview(suiController.view)
    suiController.view.backgroundColor = .clear
    
    self.view.addSubview(slidersStackView)
    let stackViewHeight: CGFloat = 150.0
    slidersStackView.frame = CGRect(x: 0, y: self.view.bounds.height - stackViewHeight - 25, width: self.view.bounds.width, height: stackViewHeight)
    
    self.view.addSubview(dropDownButton)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Reset view upon disappearance
    self.view.subviews.forEach { $0.removeFromSuperview() }
    self.children.forEach { $0.removeFromParent() }
  }
  
  //MARK: UI Target Actions
  
  @objc func xSliderChanged() {
    suiController.view.center.x = originalOverlayCenter.x + CGFloat(xSlider.value)
  }
  
  @objc func ySliderChanged() {
    suiController.view.center.y = originalOverlayCenter.y + CGFloat(ySlider.value)
  }
  
  @objc func alphaSliderChanged() {
    suiController.view.alpha = CGFloat(alphaSlider.value)
  }
  
  //MARK: Flutter Stream Handler
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    nil
  }
}
