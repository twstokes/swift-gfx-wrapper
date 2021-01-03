//
//  Colorable.swift
//  SwiftGFXWrapperExample
//
//  Created by Tanner W. Stokes on 3/14/21.
//

import Foundation

/// Converts a color to a 565 16-bit RGB value.
public protocol Colorable {
    func to565() -> Int
}
