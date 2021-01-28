/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Alamofire
import Foundation

/// The protocol for all api calls
protocol ApiClientProtocol {

	/// Get the agent details
	/// - Parameters:
	///   - identifier: the identifer of the event
	///   - completionHandler: the completion handler
	func getAgentEnvelope(identifier: String, completionHandler: @escaping (AgentEnvelope?) -> Void)

	/// Get the event details
	/// - Parameters:
	///   - identifier: the event identifier
	///   - completionHandler: completion handler
	func getEvent(identifier: String, completionHandler: @escaping (EventEnvelope?) -> Void)

	/// Get the public keys
	/// - Parameter completionHandler: completion handler
	func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void)

	/// Get the test results
	/// - Parameters:
	///   - identifier: the identifier of the user
	///   - completionHandler: the completion handler
	func getTestResults(identifier: String, completionHandler: @escaping (TestResultEnvelope?) -> Void)

	/// Get the test results
	/// - Parameters:
	///   - token: the access token
	///   - completionHandler: the completion handler
	func getTestResultsWithToken(token: String, completionHandler: @escaping (TestResultEnvelope?) -> Void)

	/// Post the authorization token
	/// - Parameters:
	///   - token: the authorization token
	///   - completionHandler: the completion handler
	func postAuthorizationToken(_ token: String, completionHandler: @escaping (Bool) -> Void)
}

/// The Api Client for all API Calls.
class ApiClient: ApiClientProtocol {

	/// Get the agent details
	/// - Parameters:
	///   - identifier: the identifer of the event
	///   - completionHandler: the completion handler
	func getAgentEnvelope(identifier: String, completionHandler: @escaping (AgentEnvelope?) -> Void) {

		AF.request(
			ApiRouter.agent(identifier: identifier)
		)
		.responseDecodable(of: AgentEnvelope.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object)

				case .failure:
					completionHandler(nil)
			}
		}
	}

	/// Get the event details
	/// - Parameters:
	///   - identifier: the event identifier
	///   - completionHandler: completion handler
	func getEvent(identifier: String, completionHandler: @escaping (EventEnvelope?) -> Void) {

		AF.request(
			ApiRouter.event(identifier: identifier)
		)
		.responseDecodable(of: EventEnvelope.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object)

				case .failure:
					completionHandler(nil)
			}
		}
	}

	/// Get the public keys
	/// - Parameter completionHandler: completion handler
	func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void) {

		AF.request(
			ApiRouter.publicKeys
		)
		.responseDecodable(of: Issuers.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object.issuers)

				case .failure:
					completionHandler([])
			}
		}
	}

	/// Get the test results
	/// - Parameters:
	///   - identifier: the identifier of the user
	///   - completionHandler: the completion handler
	func getTestResults(identifier: String, completionHandler: @escaping (TestResultEnvelope?) -> Void) {

		AF.request(
			ApiRouter.testResults(identifier: identifier)
		)
		.responseDecodable(of: TestResultEnvelope.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object)

				case let .failure(error):
					print(error)
					completionHandler(nil)
			}
		}
	}

	/// Get the test results
	/// - Parameters:
	///   - token: the access token
	///   - completionHandler: the completion handler
	func getTestResultsWithToken(token: String, completionHandler: @escaping (TestResultEnvelope?) -> Void) {

		AF.request(
			ApiRouter.testResultsWithAuthToken(token: token)
		)
		.responseDecodable(of: TestResultEnvelope.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object)

				case let .failure(error):
					print(error)
					completionHandler(nil)
			}
		}
	}

	/// Post the authorization token
	/// - Parameters:
	///   - token: the authorization token
	///   - completionHandler: the completion handler
	func postAuthorizationToken(_ token: String, completionHandler: @escaping (Bool) -> Void) {

		AF.request(
			ApiRouter.authorizationToken(token: token)
		).response { response in

			switch response.result {
				case .success:
					completionHandler(true)

				case let .failure(error):
					print(error)
					completionHandler(false)
			}
		}
	}
}
