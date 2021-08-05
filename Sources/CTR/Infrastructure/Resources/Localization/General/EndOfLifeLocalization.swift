/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// Localization for update app

extension String {

	static var endOfLifeTitle: String {
		
		return Localization.string(for: "endOfLife.title")
	}

	static var endOfLifeDescription: String {

		return Localization.string(for: "endOfLife.description")
	}

	static var endOfLifeErrorMessage: String {

		return Localization.string(for: "endOfLife.error.message")
	}

	static var endOfLifeButton: String {

		return Localization.string(for: "endOfLife.button")
	}
}
