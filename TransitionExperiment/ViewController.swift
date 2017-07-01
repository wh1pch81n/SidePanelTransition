//
//  ViewController.swift
//  TransitionExperiment
//
//  Created by Derrick Ho on 7/1/17.
//  Copyright © 2017 Derrick Ho. All rights reserved.
//

import UIKit

extension UIView {
    var imageValue: UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return screenshot
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedView(_:))))
        
    }
    
    @objc private func tappedView(_ sender: Any) {
        print(#function)
        guard presentedViewController == nil else {
            dismiss(animated: true) { }
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: String(describing:  SettingsViewController.self))
        settingsVC.transitioningDelegate = self
        settingsVC.modalPresentationStyle = .custom
        present(settingsVC, animated: true) { }
    }
    
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MyPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class SettingsViewController: UIViewController {
    override func loadView() {
        super.loadView()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedView(_:))))
    }
    
    @objc private func tappedView(_ sender: Any) {
        print(#function)
        dismiss(animated: true) { }
    }
}

class MyPresentationController: UIPresentationController {
    
}

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var percentSlide: CGFloat = 0.8
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.view(forKey: .to)!
        if !transitionContext.containerView.subviews.contains(toVC) {
            transitionContext.containerView.addSubview(toVC)
        }
        let fromVC = transitionContext.viewController(forKey: .from)!.view!
        fromVC.superview?.bringSubview(toFront: fromVC)
        
        toVC.frame = UIScreen.main.bounds
        fromVC.frame = UIScreen.main.bounds
        var finalDestination = fromVC.frame
        finalDestination.origin.x = fromVC.frame.origin.x + fromVC.frame.width * percentSlide
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.frame = finalDestination
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
class DismissingAnimator: PresentingAnimator {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)!.view!
        
        let fromVC = transitionContext.view(forKey: .from)!
        if !transitionContext.containerView.subviews.contains(fromVC) {
            transitionContext.containerView.addSubview(fromVC)
        }
        toVC.superview?.bringSubview(toFront: toVC)
        
        toVC.frame = UIScreen.main.bounds
        toVC.frame.origin.x = toVC.frame.origin.x + toVC.frame.width * percentSlide
        fromVC.frame = UIScreen.main.bounds
        
        let finalDestination = UIScreen.main.bounds
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.frame = finalDestination
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
