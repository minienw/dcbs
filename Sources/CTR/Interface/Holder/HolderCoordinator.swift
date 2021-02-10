/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol HolderCoordinatorDelegate: AnyObject {

	// MARK: Navigation

	/// Navigate to the start fo the holder flow
	func navigateToStart()

	/// Navigate to appointment
	func navigateToAppointment()

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults()

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR()

	// MARK: Menu

	/// Close the menu
	func closeMenu()

	/// Open a menu item
	/// - Parameter identifier: the menu identifier
	func openMenuItem(_ identifier: MenuIdentifier)
}

class HolderCoordinator: Coordinator, Logging {

	var loggingCategory: String = "HolderCoordinator"

	/// The UI Window
	private var window: UIWindow

	var coronaTestProof: CTRModel?

	/// The side panel controller
	var sidePanel: SidePanelController?

	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	var dashboardNavigationContoller: UINavigationController?

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self
			)
			startChildCoordinator(coordinator)

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent()
		} else {
			// Start with the holder app
			navigateToHolderStart()
		}
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {

	// MARK: Navigation

	func navigateToHolderStart() {

		let menu = HolderMenuViewController(
			viewModel: HolderMenuViewModel(
				coordinator: self
			)
		)
		sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))

		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self
			)
		)
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}

	/// Navigate to appointment
	func navigateToAppointment() {

		let destination = AppointmentViewController(
			viewModel: AppointmentViewModel(
				coordinator: self
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the Fetch Result Scene
	func navigateToFetchResults() {

		let viewController = HolderFetchResultViewController(
			viewModel: FetchResultViewModel(
				coordinator: self,
				openIdClient: OpenIdClient(configuration: Configuration()),
				userIdentifier: coronaTestProof?.userIdentifier
			)
		)

		navigationController.pushViewController(viewController, animated: true)
	}

	// Navigate to the Generate Holder QR Scene
	func navigateToHolderQR() {

		let viewController = HolderGenerateQRViewController(viewModel: GenerateQRViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to the start fo the holder flow
	func navigateToStart() {

		navigationController.popToRootViewController(animated: true)
	}

	// MARK: Menu

	/// Close the menu
	func closeMenu() {

		sidePanel?.hideSidePanel()
	}

	/// Open a menu item
	/// - Parameter identifier: the menu identifier
	func openMenuItem(_ identifier: MenuIdentifier) {

		switch identifier {
			case .overview:
				dashboardNavigationContoller?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationContoller
			default:
				self.logInfo("User tapped on \(identifier), not implemented")
		}
	}
}

extension HolderCoordinator: OnboardingDelegate {

	/// User has seen all the onboarding pages
	func finishOnboarding() {

		onboardingManager.finishOnboarding()
	}

	/// The onboarding is finished
	func consentGiven() {

		// Mark as complete
		onboardingManager.consentGiven()

		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to Holder Start.
		navigateToHolderStart()
	}
}