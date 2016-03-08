//
//  ApplicationState.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 07.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import Foundation
import UIKit

enum UIApplicationState {
    case Foreground
    case Background
}

protocol ApplicationStateObservable {
    var applicationState: UIApplicationState { get set }
    func didEnterBackground()
    func didEnterForeground()
}