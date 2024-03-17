//
//  Settings.swift
//  ios to do app
//
//  Created by Cristi Conecini on 24.01.23.
//

import Foundation
import SwiftUI
// Settings.swift: SwiftUI code for the iOS to-do app.
// Contains a global array of predefined tint colors and a structure to represent a single tint color.
// Also contains an extension to the Color struct to return a hexadecimal string representation of the color.

// Global array of predefined tint colors, represented as hexadecimal strings.
let TINT_COLORS = ["#007AFF", "#18eb09","#e802e0","#eb7a09"]

// Structure to represent a single tint color.
struct TintColor {
    // The name of the tint color.
    let name: String
    
    // The hexadecimal representation of the tint color.
    let colorHex: String
    
    /// Initializer to set the name and hexadecimal representation of a tint color.
    /// - Parameters:
    ///   - colorHex: the hexadecimal string representation of the tint color.
    init(colorHex: String){
        self.colorHex = colorHex
        
        // Switch statement to set the name of the tint color based on its hexadecimal representation.
        switch (colorHex){
        case "#025ee8": self.name = "Blue"
        case "#18eb09": self.name = "Green"
        case "#e802e0": self.name = "Magenta"
        case "#eb7a09": self.name = "Orange"
        default: self.name = "Blue"
        }
    }
    
    // Computed property to return a Color representation of the tint color.
    var color: Color {
        Color(hex: colorHex)
    }
}


// Extension to the Color struct to return a hexadecimal string representation of the color.
extension Color {
    /// Function to convert a Color to a hexadecimal string representation.
    /// - Returns:
    ///  - The hexadecimal string representation of the Color.
    func toHex() -> String? {
        // Convert the Color to a UIColor.
        let uic = UIColor(self)
        
        // Check if the UIColor has color components.
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        // Set the red, green, and blue components of the Color.
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        // If the UIColor has an alpha component, set it.
        if components.count >= 4 {
            a = Float(components[3])
        }

        // Return the hexadecimal string representation of the Color.
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
