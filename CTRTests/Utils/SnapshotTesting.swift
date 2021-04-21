//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import SnapshotTesting
import UIKit

internal extension UIViewController {
    func assertImage(
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        UIScreen.main.assertSimulatorIsAllowedForSnapshotTesting()

        SnapshotTesting.assertSnapshot(
            matching: self,
            as: .image,
            file: file,
            testName: testName,
            line: line
        )
    }
}

private extension UIScreen {
    func assertSimulatorIsAllowedForSnapshotTesting() {
        // All tests must be run on an iPhone 12-sized Simulator due to differing pixel density issues,
        // see issue: https://github.com/pointfreeco/swift-snapshot-testing/issues/174

        precondition(
            bounds.size.width.isEqual(to: 390) && bounds.size.height.isEqual(to: 844),
            "😯📲 Failure: You must run the snapshot tests on an iPhone 12-sized simulator due to this reason: https://github.com/pointfreeco/swift-snapshot-testing/issues/174\nCurrent size: \(bounds.size)"
        )
    }
}
