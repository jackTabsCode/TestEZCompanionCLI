import ArgumentParser
import TOMLDecoder
import Vapor

struct Cli: ParsableCommand {
	@ArgumentParser.Flag(name: .long, help: "Only print failures")
	var onlyPrintFailures: Bool = false
}

let cli = try Cli.parse()

let contents = try String(contentsOfFile: "testez-companion.toml")
let decoder = TOMLDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let config = try decoder.decode(Config.self, from: contents)

let state = AppState(config: config, onlyLogFailures: cli.onlyPrintFailures)

Task.detached {
	let startTime = Date()
	try await Task.sleep(nanoseconds: 1_000_000_000)

	print("Waiting for place(s) to check in...")

	while true {
		let elapsed = Date().timeIntervalSince(startTime)
		if elapsed > 5 {
			print("No places have reported anything. Studio might not be open?")
			exit(1)
		}

		let placesCount = await state.placesCount()
		let key: String?
		if placesCount == 0 {
			key = nil
		} else if placesCount == 1 {
			key = await state.firstPlaceKey()
		} else {
			key = await inquirePlace(state: state)
		}

		if let key = key {
			print("Waiting for results from place \(key)...")
			await state.setActivePlace(key)
			break
		} else {
			continue
		}
	}
}

let app = Application(.production)
app.logger.logLevel = .warning
app.http.server.configuration.port = 28859
app.routes.defaultMaxBodySize = "10mb"

defer { app.shutdown() }

app.get("poll") { req -> Response in
	return await apiPoll(req: req, state: state)
}

app.post("logs") { req -> Response in
	return await apiLogs(req: req, state: state)
}

app.post("results") { req -> Response in
	return await apiResults(req: req, state: state)
}

try await app.execute()

func inquirePlace(state: AppState) async -> String? {
	let options = await state.getPlacesOptions()

	print("Select a place to run tests on:")
	for (index, option) in options.enumerated() {
		print("\(index + 1). \(option)")
	}

	print("Enter the number of your choice:")
	if let input = readLine(), let choice = Int(input), choice > 0, choice <= options.count {
		let selected = options[choice - 1]
		if let key = selected.components(separatedBy: "[").last?.trimmingCharacters(
			in: CharacterSet(charactersIn: "[]"))
		{
			return key
		}
	}

	return nil
}
