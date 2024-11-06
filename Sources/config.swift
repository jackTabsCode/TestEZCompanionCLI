import AnyCodable

struct Config: Decodable {
	let roots: [String]
	let testExtraOptions: [String: AnyCodable]?

	enum CodingKeys: String, CodingKey {
		case roots
		case testExtraOptions = "test_extra_options"
	}
}

struct ConfigResponse: Encodable {
	let testRoots: [String]
	let testExtraOptions: [String: AnyCodable]

	enum CodingKeys: String, CodingKey {
		case testRoots
		case testExtraOptions
	}
}
