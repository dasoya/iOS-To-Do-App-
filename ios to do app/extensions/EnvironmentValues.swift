//
//  EnvironmentValues.swift
//  ios to do app
//
//  Created by Cristi Conecini on 24.01.23.
//

import Foundation
import SwiftUI

class TintColorKey: EnvironmentKey{
    static let defaultValue: Color = Color(hex: "#025ee8")
}


extension EnvironmentValues{
    var tintColor: Color {
        get { self[TintColorKey.self] }
        set { self[TintColorKey.self] = newValue}
    }
}
