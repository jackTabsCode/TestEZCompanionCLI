import Vapor

func apiPoll(req: Request, state: AppState) async -> Response {
	guard let placeGuid = req.headers.first(name: "place-guid"),
	      let placeName = req.headers.first(name: "place-name"),
	      let placeIdStr = req.headers.first(name: "place-id"),
	      let placeId = UInt64(placeIdStr)
	else {
		return Response(status: .badRequest)
	}

	let place = Place(name: placeName, id: placeId)

	if let activePlace = await state.getActivePlace(), activePlace == placeGuid {
		let response = ConfigResponse(
			testRoots: state.config.roots,
			testExtraOptions: state.config.testExtraOptions ?? [:]
		)
		let data = try! JSONEncoder().encode(response)

		return Response(status: .ok, body: .init(data: data))
	} else {
		await state.insertPlace(key: placeGuid, place: place)

		return Response(status: .forbidden)
	}
}
