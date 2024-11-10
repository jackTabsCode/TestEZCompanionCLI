import Vapor

enum MessageType: Int, Codable {
	case output = 0
	case info = 1
	case warning = 2
	case error = 3
}

struct Log: Codable {
	let message: String
	let messageType: MessageType
}

func apiLogs(req: Request, state: AppState) async -> Response {
	do {
		let log = try req.content.decode(Log.self)

		switch log.messageType {
		case .output, .info:
			print("Output: \(log.message)")
		case .warning:
			print("Warning: \(log.message)")
		case .error:
			print("Error: \(log.message)")
		}

		return Response(status: .ok)
	} catch {
		return Response(status: .badRequest)
	}
}
