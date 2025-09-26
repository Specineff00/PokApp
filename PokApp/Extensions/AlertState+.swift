import ComposableArchitecture

extension AlertState {
    static var defaultPokApp: Self {
        AlertState {
            TextState("Woops")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Something went wrong!")
        }
    }
}
