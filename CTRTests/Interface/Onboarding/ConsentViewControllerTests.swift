/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ConsentViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ConsentViewController?

	var coordinatorSpy = OnboardingCoordinatorSpy()

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		sut = ConsentViewController(
			viewModel: ConsentViewModel(
				coordinator: coordinatorSpy,
				factory: HolderOnboardingFactory()
			)
		)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		if let sut = sut {
			window.addSubview(sut.view)
			RunLoop.current.run(until: Date())
		}
	}

	// MARK: Test

	/// Test all the content without consent
	func testContent() throws {

		// Given

		// When
		loadView()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.sceneView.title, .holderConsentTitle, "Title should match")
		XCTAssertEqual(strongSut.sceneView.message, .holderConsentMessage, "Message should match")
		XCTAssertEqual(strongSut.sceneView.consent, .holderConsentButtonTitle, "Consent should match")
		XCTAssertEqual(strongSut.sceneView.itemStackView.arrangedSubviews.count, 3, "There should be 3 items")
	}

	/// Test the user tapped on the link
	func testLink() {

		// Given
		loadView()

		// When
		sut?.linkTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.showPrivacyPageCalled, "Method should be called")
	}

	/// Test the user tapped on the consent button
	func testConsentGivenTrue() throws {

		// Given
		loadView()
		let button = ConsentButton()
		button.isSelected = true

		// When
		sut?.consentValueChanged(button)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.viewModel.isContinueButtonEnabled, "Button should be enabled")
	}

	/// Test the user tapped on the consent button
	func testConsentGivenFalse() throws {

		// Given
		loadView()
		let button = ConsentButton()
		button.isSelected = false

		// When
		sut?.consentValueChanged(button)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.viewModel.isContinueButtonEnabled, "Button should not be enabled")
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedEnabled() {

		// Given
		loadView()
		sut?.sceneView.primaryButton.isEnabled = true

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(coordinatorSpy.consentGivenCalled, "Method should be called")
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedDisabled() {

		// Given
		loadView()
		sut?.sceneView.primaryButton.isEnabled = false

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertFalse(coordinatorSpy.consentGivenCalled, "Method should not be called")
	}
}
