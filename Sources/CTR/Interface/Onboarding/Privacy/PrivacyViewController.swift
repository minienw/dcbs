/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PrivacyViewController: BaseViewController {

	/// The model
	private let viewModel: PrivacyViewModel

	/// The view
	let sceneView = PrivacyView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: PrivacyViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Show always in portrait
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { self.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCloseButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .cross,
			style: .plain,
			target: self,
			action: action
		)
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = accessibilityLabel
		button.accessibilityTraits = UIAccessibilityTraits.button
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = button
		navigationController?.navigationItem.rightBarButtonItem = button
	}
}