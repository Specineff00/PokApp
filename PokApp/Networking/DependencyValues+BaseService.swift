import Dependencies

extension DependencyValues {
    var baseService: any BaseServiceProtocol {
        get { self[BaseServiceKey.self] }
        set { self[BaseServiceKey.self] = newValue }
    }
}

private enum BaseServiceKey: DependencyKey {
    static let liveValue: any BaseServiceProtocol = LiveBaseService()
    static let testValue: any BaseServiceProtocol = MockBaseService { _ in
        Pokemon.mock()
    }
}
