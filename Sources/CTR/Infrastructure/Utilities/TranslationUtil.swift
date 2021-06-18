//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
import UIKit
import Foundation

extension UILabel {

    @IBInspectable var translationKey: String? {
        set (newValue) {
            if let key = newValue {
                text = Localization.string(for: key)
            }
        }
        get {
            return text
        }
    }
}

extension UIButton {

    @IBInspectable var translationKey: String? {
        set (newValue) {
            if let key = newValue {
                setTitle(Localization.string(for: key), for: .normal)
            }
        }
        get {
            return title(for: .normal)
        }
    }

}
