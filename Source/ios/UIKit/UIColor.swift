//
//  UIColor.swift
//  Created by Vadim Pavlov on 23.07.16.

import UIKit

public extension UIColor {

    static var clearWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.0)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    // MARK: - HEX
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    convenience init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexInt: UInt32 = 0
        Scanner(string: trimmed).scanHexInt32(&hexInt)
        self.init(hex: Int(hexInt))
    }

    var hex: String {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1 {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)),
                          lroundf(Float(a * 255)))
        }
    }
    
}

public extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1)
    }
}
