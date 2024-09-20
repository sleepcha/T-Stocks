//
//  UIColor+Extension.swift
//  T-Stocks
//
//  Created by sleepcha on 9/15/24.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgbValue) else { return nil }

        let length = hex.count
        switch length {
        case 6: // RRGGBB
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        case 8: // RRGGBBAA
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        default:
            return nil
        }
    }
}
