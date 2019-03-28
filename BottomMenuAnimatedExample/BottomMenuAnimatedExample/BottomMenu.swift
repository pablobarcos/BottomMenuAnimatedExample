//
//  BottomMenu.swift
//  BottomMenuAnimatedExample
//
//  Created by Pablo Barcos on 28/03/2019.
//  Copyright © 2019 Pablo Barcos. All rights reserved.
//

import Foundation
import UIKit

private enum State {
    case closed
    case open
}
extension State {
    var opposite: State {
        switch self {
        case .open:
            return .closed
        case .closed:
            return .open
        }
    }
}

class BottomMenu {
    
    //static let sharedInstance = BottomMenu()
    
    var view: UIView
    
    private let menuOffset: CGFloat = 440
    private var bottomConstraint = NSLayoutConstraint()
    
    
    // MARK: - Animation
    
    /// The current state of the animation. This variable is changed only when an animation completes.
    private var currentState: State = .closed
    
    /// All of the currently running animators.
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    /// The progress of each animator. This array is parallel to the `runningAnimators` array.
    private var animationProgress = [CGFloat]()
    
    init(view: UIView) {
        self.view = view
    }
    
    //Create views
    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    var menuView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        //specify which corners to round
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Menu"
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Menu"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    
    var contentViewMenu: MenuContentView = {
        let view = MenuContentView()
        
        return view
    }()
    
    func layout() {
        
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuView)
        menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: menuOffset)
        bottomConstraint.isActive = true
        menuView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        menuView.addSubview(headerView)
        headerView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: menuView.topAnchor).isActive = true
        bottomConstraint.isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: menuView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: menuView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30).isActive = true
        
        contentViewMenu.translatesAutoresizingMaskIntoConstraints = false
        menuView.addSubview(contentViewMenu)
        contentViewMenu.leadingAnchor.constraint(equalTo: menuView.leadingAnchor).isActive = true
        contentViewMenu.trailingAnchor.constraint(equalTo: menuView.trailingAnchor).isActive = true
        contentViewMenu.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10).isActive = true
        
        let panRecognizer = InstantPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(menuViewPanned(recognizer:)))
        
        headerView.addGestureRecognizer(panRecognizer)
    }
    
    /// Animates the transition, if the animation is not already running.
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.menuView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
                //Animate title
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
            case .closed:
                self.bottomConstraint.constant = self.menuOffset
                self.menuView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
                //Animate title
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
            }
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                break
            }
            
            // manually reset the constraint positions
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.menuOffset
            }
            
            // remove all running animators
            self.runningAnimators.removeAll()
            
        }
        
        // an animator for the title that is transitioning into view
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            switch state {
            case .open:
                self.openTitleLabel.alpha = 1
            case .closed:
                self.closedTitleLabel.alpha = 1
            }
        })
        inTitleAnimator.scrubsLinearly = false
        
        // an animator for the title that is transitioning out of view
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            switch state {
            case .open:
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.openTitleLabel.alpha = 0
            }
        })
        outTitleAnimator.scrubsLinearly = false
        
        // start all animators
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
        
    }
    
    @objc private func menuViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // start the animations
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            
            // pause all animations, since the next event may be a pan changed
            runningAnimators.forEach { $0.pauseAnimation() }
            
            // keep track of each animator's progress
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            // variable setup
            let translation = recognizer.translation(in: menuView)
            var fraction = -translation.y / menuOffset
            
            // adjust the fraction for the current state and reversed state
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            // apply the new fraction
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            // variable setup
            let yVelocity = recognizer.velocity(in: menuView).y
            let shouldClose = yVelocity > 0
            
            // if there is no motion, continue all animations and exit early
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            // reverse the animations based on their current state and pan motion
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            
            // continue all animations
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            ()
        }
    }
}

// MARK: - InstantPanGestureRecognizer

/// A pan gesture that enters into the `began` state on touch down instead of waiting for a touches moved event.
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
    
}

