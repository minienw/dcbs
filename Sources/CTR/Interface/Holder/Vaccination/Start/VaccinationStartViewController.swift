/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VaccinationStartViewModel: Logging {

	weak var coordinator: VaccinationCoordinatorDelegate?

	var tvsToken = "508193527" // Todo: Get from DigiD

	var accessTokens = [AccessToken]()

	init(coordinator: VaccinationCoordinatorDelegate) {
		self.coordinator = coordinator
	}

	func backButtonTapped() {
		coordinator?.didFinish()
	}

	func primaryButtonTapped() {

		Services.networkManager.getAccessTokens(tvsToken: tvsToken) { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logInfo("Error getting access tokens: \(error)")
				case let .success(tokens):
					self?.accessTokens = tokens
					self?.logInfo("Access Tokens: \(self?.accessTokens.count)")
			}
		}
	}
}

class VaccinationStartViewController: BaseViewController {

	let viewModel: VaccinationStartViewModel
	let sceneView = VaccinationStartView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: VaccinationStartViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		title = "** Vaccinatie ophalen **"
		sceneView.primaryTitle = "** Login met DigiD ** "
		navigationItem.hidesBackButton = true
		addCustomBackButton(action: #selector(backButtonTapped), accessibilityLabel: .back)

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}
	}

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}

class VaccinationStartView: ScrolledStackWithButtonView {

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		showLineView = false
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupPrimaryButton(useFullWidth: {
			switch traitCollection.preferredContentSizeCategory {
				case .unspecified: return true
				case let size where size > .extraLarge: return true
				default: return false
			}
		}())
	}
}
