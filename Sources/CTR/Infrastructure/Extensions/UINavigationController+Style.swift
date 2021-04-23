/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UINavigationController {
	
	override open var preferredStatusBarStyle: UIStatusBarStyle {
		
		if #available(iOS 13.0, *) {
			return topViewController?.preferredStatusBarStyle ?? .darkContent
		} else {
			return topViewController?.preferredStatusBarStyle ?? .default
		}
	}
}

extension UINavigationController {

	/// Add a banner view to the top of the screen
	/// - Parameter bannerView: the banner view to show
	func addBannerView(_ bannerView: BannerView) {

		view.addSubview(bannerView)

		NSLayoutConstraint.activate([
			bannerView.widthAnchor.constraint(equalTo: view.widthAnchor),
			bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			bannerView.topAnchor.constraint(equalTo: view.topAnchor)
		])
	}
}
