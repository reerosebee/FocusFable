//
//  OrientationManager.swift
//  FocusFable
//

import UIKit
import SwiftUI

/// Manages per-screen orientation locking.
final class OrientationManager {

    static let shared = OrientationManager()
    private init() {}

    private(set) var current: UIInterfaceOrientationMask = .portrait

    func lock(_ orientation: UIInterfaceOrientationMask) {
        current = orientation
        // Tell the system to re-evaluate supported orientations
        if let scene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            scene.requestGeometryUpdate(
                .iOS(interfaceOrientations: orientation)
            )
        }
        // Also rotate the root view controller
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
