/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum GreenCardType: String {

	case domestic
	case eu
}

class GreenCardModel {

	static let entityName = "GreenCard"

	@discardableResult class func create(
		type: GreenCardType,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> GreenCard? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? GreenCard {

			object.type = type.rawValue
			object.wallet = wallet

			return object
		}
		return nil
	}
}
