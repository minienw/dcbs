/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifierCoordinatorDelegateSpy: VerifierCoordinatorDelegate, Dismissable {

	var navigateToVerifierWelcomeCalled = false
	var navigateToScanInstructionCalled = false
	var navigateToScanCalled = false
	var navigateToScanResultCalled = false
	var displayContentCalled = false
	var dismissCalled = false

	func navigateToVerifierWelcome() {

		navigateToVerifierWelcomeCalled = true
	}

	func navigateToScanInstruction(present: Bool) {

		navigateToScanInstructionCalled = true
	}

	func navigateToScan() {

		navigateToScanCalled = true
	}

	func navigateToScanResult(_ cryptoResult: CryptoResult) {

		navigateToScanResultCalled = true
	}

	func displayContent(title: String, content: [Content]) {

		displayContentCalled = true
	}

	func dismiss() {

		dismissCalled = true
	}
}
