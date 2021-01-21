/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol VerifierCoordinatorDelegate: AnyObject {

	/// Navigate to the Agent  Scene
	func navigateToAgent()

	// Navigate to the Customer Scan Scene
	func navigateToCustomerScan()

	// Navigate to the Test Result
	func navigateToTestResult()

	/// Navigate to the start fo the customer flow
	func navigateToStart()

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult)

	/// Set the agent envelope
	/// - Parameter event: the agentEvelope
	func setAgentEnvelope(_ agentEvelope: AgentEnvelope)

	/// Set the customer QR
	/// - Parameter result: customer QR
	func setCustomerQR(_ result: CustomerQR)

	/// Dismiss the viewcontroller
	func dismiss()
}

class VerifierCoordinator: Coordinator {

	var agentEnvelope: AgentEnvelope?

	var testResult: TestResult?

	var customerQR: CustomerQR?

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// Initiatilzer
	init(navigationController: UINavigationController) {

		self.navigationController = navigationController
	}

	// Designated starter method
	func start() {

		let viewController = VerifierStartViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {

	/// Navigate to the Agent  Scene
	func navigateToAgent() {

		let viewController = VerifierAgentScanViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Customer Scan Scene
	func navigateToCustomerScan() {

		let viewController = VerifierScanViewController()
		viewController.coordinator = self
		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Test Result
	func navigateToTestResult() {

		let viewController = VerifierResultViewController()
		viewController.coordinator = self
		viewController.valid = validateCustomerQR()
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Set the test result
	/// - Parameter result: the test result
	func setTestResult(_ result: TestResult) {

		self.testResult = result
	}

	/// Set the agent envelope
	/// - Parameter event: the agentEvelope
	func setAgentEnvelope(_ envelope: AgentEnvelope) {

		self.agentEnvelope = envelope
	}

	/// Set the customer QR
	/// - Parameter result: customer QR
	func setCustomerQR(_ result: CustomerQR) {

		self.customerQR = result
	}

	/// Navigate to the start fo the customer flow
	func navigateToStart() {

		guard navigationController.viewControllers.count > 1 else {
			return
		}
		navigationController.popToViewController(navigationController.viewControllers[1], animated: true)
	}

	/// Dismiss the viewcontroller
	func dismiss() {

		navigationController.popViewController(animated: true)
		(navigationController.viewControllers.last as? VerifierStartViewController)?.event = agentEnvelope?.agent.event
	}
}

extension VerifierCoordinator {

	func validateCustomerQR() -> Bool {

		guard let agentEnvelope = agentEnvelope,
			  let customerQR = customerQR else {
			return false
		}

		// Unencrypted

		do {
			if let data = customerQR.payload.data(using: .utf8) {
				let payload = try JSONDecoder().decode(Payload.self, from: data)

				if let result = payload.test?.result {
					return result == 0
				}

				return false
			}
		} catch let error {
			print("CTR: error! \(error)")
			return false
		}
		return false
	}

}
