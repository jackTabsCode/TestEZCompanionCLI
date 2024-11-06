struct Place {
	let name: String
	let id: UInt64
}

actor AppState {
	let config: Config
	var places: [String: Place] = [:]
	var activePlace: String?
	let onlyLogFailures: Bool

	init(config: Config, onlyLogFailures: Bool) {
		self.config = config
		self.onlyLogFailures = onlyLogFailures
	}

	func placesCount() -> Int {
		return places.count
	}

	func firstPlaceKey() -> String? {
		return places.keys.first
	}

	func getPlacesOptions() -> [String] {
		return places.map { key, place in
			"\(place.name) (\(place.id)) [\(key)]"
		}
	}

	func setActivePlace(_ key: String) {
		activePlace = key
	}

	func getActivePlace() -> String? {
		return activePlace
	}

	func insertPlace(key: String, place: Place) {
		places[key] = place
	}
}
