//
//  KeyboardVisibility.swift
//  SwiftUIKeyboardObserver
//
//  Created by Toomas Vahter on 21.03.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import SwiftUI

fileprivate final class KeyboardObserver: ObservableObject {
    struct Info {
        let curve: UIView.AnimationCurve
        let duration: TimeInterval
        let endFrame: CGRect
    }
    
    private var observers = [NSObjectProtocol]()
    
    init() {
        let handler: (Notification) -> Void = { [weak self] notification in
            self?.keyboardInfo = Info(notification: notification)
        }
        let names: [Notification.Name] = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ]
        observers = names.map({ name in
            NotificationCenter.default.addObserver(forName: name,
                                                   object: nil,
                                                   queue: .main,
                                                   using: handler)
        })
    }

    @Published var keyboardInfo = Info(curve: .linear, duration: 0, endFrame: .zero)
}

fileprivate extension KeyboardObserver.Info {
    init(notification: Notification) {
        guard let userInfo = notification.userInfo else { fatalError() }
        curve = {
            let rawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            return UIView.AnimationCurve(rawValue: rawValue)!
        }()
        duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    }
}

fileprivate extension Animation {
    init(keyboardInfo: KeyboardObserver.Info) {
        switch keyboardInfo.curve {
        case .easeInOut:
            self = .easeInOut(duration: keyboardInfo.duration)
        case .easeIn:
            self = .easeIn(duration: keyboardInfo.duration)
        case .easeOut:
            self = .easeOut(duration: keyboardInfo.duration)
        case .linear:
            self = .linear(duration: keyboardInfo.duration)
        @unknown default:
            // rdar://42609976 currently the curve returns 7
            self = .easeInOut(duration: keyboardInfo.duration)
        }
    }
}

struct KeyboardVisibility: ViewModifier {
    @ObservedObject fileprivate var keyboardObserver = KeyboardObserver()

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            withAnimation() {
                content.padding(.bottom, max(0, self.keyboardObserver.keyboardInfo.endFrame.height - geometry.safeAreaInsets.bottom))
                    .animation(Animation(keyboardInfo: self.keyboardObserver.keyboardInfo))
            }
        }
    }
}

extension View {
    func keyboardVisibility() -> some View {
        return modifier(KeyboardVisibility())
    }
}
