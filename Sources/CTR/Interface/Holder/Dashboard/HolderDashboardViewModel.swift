/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The different kind of cards
enum CardIdentifier {

	/// Make an appointment to get tested
	case appointment

	/// Create a QR code
	case create

	/// The QR code card
	case qrcode
}

/// The card information
struct CardInfo {

	/// The identifier of the card
	let identifier: CardIdentifier

	/// The title of the card
	let title: String

	/// The message of the card
	let message: String

	/// The title on the action button of the card
	let actionTitle: String

	/// The optional background image
	let image: UIImage?

	/// The background color
	let backgroundColor: UIColor?
}

/// The card information for QR
struct QRCardInfo {

	/// The identifier of the card
	let identifier: CardIdentifier

	/// The title of the card
	let title: String

	/// The message of the card
	let message: String

	/// The identiry of the holder
	let holder: String

	/// The title on the action button of the card
	let actionTitle: String

	/// The optional background image
	let image: UIImage?

	/// the valid until date
	let validUntil: String
}

class HolderDashboardViewModel: PreventableScreenCapture, Logging {

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// Coordination Delegate
	weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The configuration
	var configuration: ConfigurationGeneralProtocol

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The banner manager
	var bannerManager: BannerManaging = BannerManager.shared

	/// the notification center
	var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep refreshing the QR
	var validityTimer: Timer?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The introduction message of the scene
	@Bindable private(set) var message: String

	/// The message on the expired card
	@Bindable private(set) var expiredTitle: String?

	/// Show an expired QR Message
	@Bindable private(set) var showExpiredQR: Bool

	/// The appointment Card information
	@Bindable private(set) var appointmentCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var createCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var qrCard: QRCardInfo?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		maxValidity: Int) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
		self.title = .holderDashboardTitle
		self.message = .holderDashboardIntro
		self.expiredTitle = .holderDashboardQRExpired

		// Start by showing nothing
		self.showExpiredQR = false

		self.appointmentCard = CardInfo(
			identifier: .appointment,
			title: .holderDashboardAppointmentTitle,
			message: .holderDashboardAppointmentMessage,
			actionTitle: .holderDashboardAppointmentAction,
			image: .appointmentTile,
			backgroundColor: Theme.colors.appointment
		)
		self.createCard = CardInfo(
			identifier: .create,
			title: .holderDashboardCreateTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: .holderDashboardCreateAction,
			image: .createTile,
			backgroundColor: Theme.colors.create
		)

		self.proofValidator = ProofValidator(maxValidity: maxValidity)

		super.init()
		self.addObserver()
	}

	/// The user tapped on one of the cards
	/// - Parameter identifier: the identifier of the card
	func cardTapped(_ identifier: CardIdentifier) {

		switch identifier {
			case .appointment:
				coordinator?.navigateToAppointment()
			case .create:
				coordinator?.navigateToChooseProvider()
			case .qrcode:
				coordinator?.navigateToEnlargedQR()
		}
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = cryptoManager?.readCredential() else {
			qrCard = nil
			showExpiredQR = false
			validityTimer?.invalidate()
			validityTimer = nil
			setupCreateCard()
			return
		}

		if let sampleTimeStamp = TimeInterval(credential.sampleTime) {

			let holder = HolderTestCredentials(
				firstNameInitial: credential.firstNameInitial ?? "",
				lastNameInitial: credential.lastNameInitial ?? "",
				birthDay: credential.birthDay ?? "",
				birthMonth: credential.birthMonth ?? ""
			)
			switch proofValidator.validate(sampleTimeStamp) {
				case let .valid(validUntilDate):

					showQRMessageIsValid(validUntilDate, holder: holder)
					startValidityTimer()

				case let .expiring(validUntilDate, timeLeft):

					showQRMessageIsExpiring(validUntilDate, timeLeft: timeLeft, holder: holder)
					startValidityTimer()

				case .expired:

					logDebug("Proof is no longer valid")
					showQRMessageIsExpired()
					validityTimer?.invalidate()
					validityTimer = nil
			}
		}
		setupCreateCard()
	}

	/// Show the QR message is valid
	/// - Parameter validUntil: valid until time
	func showQRMessageIsValid(_ validUntil: Date, holder: HolderTestCredentials) {

		let validUntilDateString = printDateFormatter.string(from: validUntil)
		logDebug("Proof is valid until \(validUntilDateString)")

		let identity = holder.mapIdentity(months: String.shortMonths).map({ $0.isEmpty ? "_" : $0 }).joined(separator: " ")
		qrCard = QRCardInfo(
			identifier: .qrcode,
			title: .holderDashboardQRTitle,
			message: .holderDashboardQRSubTitle,
			holder: identity,
			actionTitle: .holderDashboardQRAction,
			image: .myQR,
			validUntil: String(format: .holderDashboardQRMessage, validUntilDateString)
		)

		showExpiredQR = false
	}

	/// Show the QR message is valid
	/// - Parameter validUntil: valid until time
	func showQRMessageIsExpiring(_ validUntil: Date, timeLeft: TimeInterval, holder: HolderTestCredentials) {

		let validUntilDateString = printDateFormatter.string(from: validUntil)
		logDebug("Proof is valid until \(validUntilDateString), expiring in \(timeLeft)")

		let identity = holder.mapIdentity(months: String.shortMonths).map({ $0.isEmpty ? "_" : $0 }).joined(separator: " ")
		qrCard = QRCardInfo(
			identifier: .qrcode,
			title: .holderDashboardQRTitle,
			message: .holderDashboardQRSubTitle,
			holder: identity,
			actionTitle: .holderDashboardQRAction,
			image: .myQR,
			validUntil: String(format: .holderDashboardQRExpiring, validUntilDateString, timeLeft.stringTime)
		)

		showExpiredQR = false

		// Cut off at the cut off time
		if timeLeft < 60 {
			validityTimer?.invalidate()
			validityTimer = Timer.scheduledTimer(
				timeInterval: timeLeft,
				target: self,
				selector: (#selector(checkQRValidity)),
				userInfo: nil,
				repeats: true
			)
		}
	}

	/// Show the QR Message is expired
	func showQRMessageIsExpired() {

		qrCard = nil
		showExpiredQR = true
	}

	/// Start the validity timer, check every 10 seconds.
	func startValidityTimer() {

		guard validityTimer == nil else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(60),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	/// User wants to close the expired QR
	func closeExpiredRQ() {

		cryptoManager?.removeCredential()
		checkQRValidity()
	}

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "CET")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "EEEE '<br>' d MMMM HH:mm"
		return dateFormatter
	}()

	@objc func showBanner() {

		bannerManager.showBanner(
			title: .holderBannerNewQRTitle,
			message: .holderBannerNewQRMessage,
			icon: UIImage.alert,
			callback: { [weak self] in

				if let url = self?.configuration.getHolderFAQURL() {
					self?.coordinator?.openUrl(url, inApp: true)
				}
			}
		)
	}

	func setupCreateCard() {

		self.createCard = CardInfo(
			identifier: .create,
			title: qrCard == nil ? .holderDashboardCreateTitle : .holderDashboardChangeTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: qrCard == nil ? .holderDashboardCreateAction : .holderDashboardChangeAction,
			image: .createTile,
			backgroundColor: Theme.colors.create
		)
	}
}

// MARK: - qrCreated

extension HolderDashboardViewModel {

	/// Add an observer for the qrCreated
	func addObserver() {

		notificationCenter.addObserver(
			self,
			selector: #selector(showBanner),
			name: .qrCreated,
			object: nil
		)
	}
}

extension TimeInterval {

	private var minutes: Int {

		return (Int(self) / 60 ) % 60
	}

	private var hours: Int {

		return Int(self) / 3600
	}

	var stringTime: String {

		if hours != 0 {
			return "\(hours) \(String.hour) \(minutes) \(String.minute)"
		} else if minutes != 0 {
			return "\(minutes) \(String.minute)"
		} else {
			return  "1 \(String.minute)"
		}
	}
}
