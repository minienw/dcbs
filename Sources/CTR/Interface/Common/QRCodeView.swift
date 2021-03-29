/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRCodeView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 50

		// Margins
		static let margin: CGFloat = 16.0
		static let buttonOffset: CGFloat = 27.0
		static let imageViewOffset: CGFloat = 10.0
		static let buttonSpacing: CGFloat = 40.0
	}

	/// The stackview to house all elements
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = 40.0
		return view
	}()

	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.orange
		return view
	}()

	/// the scan button
	private let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground

		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		setupStackView()
		addSubview(stackView)
	}

	/// Setup the stack view
	private func setupStackView() {

		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(primaryButton)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		NSLayoutConstraint.activate([

			// Stackview
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
			stackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Primary Button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.buttonOffset
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.buttonOffset
			),

			// CameraView
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.imageViewOffset
			),
			imageView.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.imageViewOffset
			)
		])
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	var qrImage: UIImage? {
		didSet {
			imageView.image = qrImage
		}
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}
