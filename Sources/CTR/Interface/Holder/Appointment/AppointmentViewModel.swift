/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "AppointmentViewModel"

	/// Coordination Delegate
	weak var coordinator: OpenUrlProtocol?

	/// The header image
	@Bindable private(set) var image: UIImage?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The header of the scene
	@Bindable private(set) var header: String

	/// The information body of the scene
	@Bindable private(set) var body: String

	/// The title on the button
	@Bindable private(set) var buttonTitle: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - maxValidity: the maximum validity of a test result
	init(coordinator: OpenUrlProtocol, maxValidity: Int) {

		self.coordinator = coordinator

		self.title = .holderAppointmentTitle
		self.header = .holderAppointmentHeader
		let maxValidityAsString = "\(maxValidity)"
		self.body = String(format: .holderAppointmentBody, maxValidityAsString, maxValidityAsString)
		self.buttonTitle = .holderAppointmentButtonTitle
		self.image = UIImage.appointment
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	/// The user wants to create an appointment
	func buttonTapped() {

		logInfo("Create appointment tapped")
		if let url = URL(string: .holderUrlAppointment) {
			coordinator?.openUrl(url, inApp: true)
		}
	}
}
