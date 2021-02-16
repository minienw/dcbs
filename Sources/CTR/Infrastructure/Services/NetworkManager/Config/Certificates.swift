/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CryptoKit
import Foundation
import Security

struct Certificate {
    typealias Signature = String

    let secCertificate: SecCertificate

    init?(string: String) {
        let content = string.replacingOccurrences(of: "\n", with: "")

        guard let data = Data(base64Encoded: content),
            let secCertificate = SecCertificateCreateWithData(nil, data as CFData) else {
            return nil
        }

        self.secCertificate = secCertificate
    }

    init(certificate: SecCertificate) {
        self.secCertificate = certificate
    }

    var signature: Signature? {
        let data = SecCertificateCopyData(secCertificate) as Data
        
        return data.sha256.base64EncodedString()
    }
}

extension Certificate {
    struct SSL {
        static let apiSignature: Certificate.Signature = "BocmAzGnJAPZCfEF5pvPDTLhvSST/8bZIG0RvNZ3Bzk="
		static let apiV2Signature: Certificate.Signature = "TSSRQUz+lWdG7Ezvps9vcuKKEylDL52KkHrEy12twVo="
		static let cdnSignature: Certificate.Signature = "PE+wuVq4swAy9DK4b1Nf4XLBhdD9OYZYN882GH+m9Cg="
		static let cdnV2V3Signature: Certificate.Signature = "TSSRQUz+lWdG7Ezvps9vcuKKEylDL52KkHrEy12twVo="
    }
}
