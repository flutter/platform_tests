// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

class OverlayViewController: UIViewController {
    var firstPageNC = UINavigationController()
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    var button = UIButton(frame: CGRect(x: 20, y: 50, width: 50, height: 20))

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addChild(firstPageNC)
        firstPageNC.view.frame = view.bounds
        firstPageNC.didMove(toParent: self)
        view.addSubview(firstPageNC.view)
        firstPageNC.view.backgroundColor = .clear
        firstPageNC.view.center.y += CGFloat(firstPageNC.view.frame.midY)
        
        label.frame.origin.y = view.center.y / 2
        label.center.x = firstPageNC.view.center.x
        label.textAlignment = .center
        label.text = "This should be covered by next page"
        firstPageNC.view.addSubview(label)
        
        button.setTitle("Push", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(push), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func push() {
        let secondPageVC = UIViewController()
        secondPageVC.view.frame = firstPageNC.view.frame
        secondPageVC.view.backgroundColor = .green
        
        firstPageNC.pushViewController(secondPageVC, animated: true)
        
        button.setTitle("Pop", for: .normal)
        button.removeTarget(self, action: #selector(push), for: .touchUpInside)
        button.addTarget(self, action: #selector(pop), for: .touchUpInside)
    }
    
    @objc func pop() {
        print("pop")
        firstPageNC.popViewController(animated: true)
        
        button.setTitle("Push", for: .normal)
        button.removeTarget(self, action: #selector(pop), for: .touchUpInside)
        button.addTarget(self, action: #selector(push), for: .touchUpInside)
    }
}
