import Vapor

enum PlanNodeType: String, Codable {
	case describe = "Describe"
	case it = "It"
	case beforeAll = "BeforeAll"
	case afterAll = "AfterAll"
	case beforeEach = "BeforeEach"
	case afterEach = "AfterEach"
}

enum ModifierType: String, Codable {
	case none = "None"
	case skip = "Skip"
	case focus = "Focus"
}

struct PlanNode: Codable {
	let phrase: String?
	let type: PlanNodeType?
	let modifier: ModifierType?
	let children: [PlanNode]
}

enum ReporterStatus: String, Codable {
	case success = "Success"
	case failure = "Failure"
	case skipped = "Skipped"
}

struct ReporterChildNode: Codable {
	let status: ReporterStatus
	let children: [ReporterChildNode]
	let planNode: PlanNode
	let errors: [String]
}

struct ReporterOutput: Codable {
	let failureCount: UInt32
	let successCount: UInt32
	let errors: [String]
	let skippedCount: UInt32
	let planNode: PlanNode
	let children: [ReporterChildNode]
}

func apiResults(req: Request, state: AppState) async -> Response {
	do {
		let output = try req.content.decode(ReporterOutput.self)
		let console = Terminal()
		let success = await printChildren(state: state, console: console, children: output.children)

		console.output("")
		console.output("✓ Success: \(output.successCount)".consoleText(.success))
		console.output("X Failure: \(output.failureCount)".consoleText(.error))
		console.output("↪ Skip: \(output.skippedCount)".consoleText(.info))

		Task.detached {
			try? await Task.sleep(nanoseconds: 100_000_000)
			exit(success ? 0 : 1)
		}

		return Response(status: .ok)
	} catch {
		print("Error decoding ReporterOutput: \(error)")
		return Response(status: .badRequest)
	}
}

func printChildren(state: AppState, console: Console, children: [ReporterChildNode], indent: Int = 0) async -> Bool {
	var success = true

	for child in children {
		if state.onlyLogFailures && child.status != .failure {
			continue
		}

		let indentString = String(repeating: " ", count: indent)
		let phrase = child.planNode.phrase ?? "<No Phrase>"
		var styledPhrase: ConsoleText

		switch child.status {
		case .success:
			styledPhrase = "✓ \(phrase)".consoleText(.success)
		case .failure:
			success = false
			styledPhrase = "X \(phrase)".consoleText(.error)
		case .skipped:
			styledPhrase = "↪ \(phrase)".consoleText(.info)
		}

		console.output(indentString.consoleText() + styledPhrase)

		for error in child.errors {
			let indentedError = error.split(separator: "\n").map { line in
				"\(indentString)  \(line)"
			}.joined(separator: "\n")
			console.error(indentedError)
		}

		if await !printChildren(state: state, console: console, children: child.children, indent: indent + 2) {
			success = false
		}
	}
	return success
}
