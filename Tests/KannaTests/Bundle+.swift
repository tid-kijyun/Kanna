//
//  Bundle+.swift
//  Tests
//
//  Created by Atsushi Kiwaki on 2024/02/22.
//  Copyright © 2024 Atsushi Kiwaki. All rights reserved.
//

import Foundation

extension Bundle {
    static func testBundle(for aClass: AnyClass) -> Bundle {
#if SWIFT_PACKAGE
        module
#else
        Bundle(for: aClass)
#endif
    }
}
