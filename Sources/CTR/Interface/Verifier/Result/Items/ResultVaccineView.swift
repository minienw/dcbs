//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

class ResultVaccineView: TMCBaseView {
    
    @IBOutlet var doseLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func setup(vaccine: DCCVaccine) {
        doseLabel.text = "item_dose_x_x".localized(params: vaccine.doseNumber ?? 0, vaccine.totalSeriesOfDoses ?? 0)
        productLabel.text = vaccine.getVaccineProduct?.displayName ?? ""
        dateLabel.text = vaccine.dateOfVaccination ?? ""
    }
    
}
