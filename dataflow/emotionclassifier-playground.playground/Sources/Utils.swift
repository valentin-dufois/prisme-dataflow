import Foundation

/// Load and store phrases from a CSV url
///
/// - Parameter url: URL to a CSV file containing emotives phrases data
public func loadDataFrom(_ url: URL) -> [String: String] {
	// Get the phrases
	guard let rawPhrases = try? String(contentsOf: url, encoding: .utf8) else {
		fatalError("Could not retrieve phrases from \(url.absoluteString)")
	}

	var phrases:[String: String] = [String: String]()

	// Filter and format to Emotive phrases
	rawPhrases
		.components(separatedBy: "\n")
		.map{ $0.components(separatedBy: "|") }
		.filter{ $0.count == 2 && $0[1].count > 0 }
		.forEach {
			phrases[$0[1]] = $0[0]
	}

	return phrases
}
