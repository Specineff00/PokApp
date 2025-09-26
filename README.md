# Install instructions

- Open project
- Allow packages to resolve
- Go to warnings. If no warnings, then attempt to build
- When the macro warnings/errors show, tap and choose to trust. This is a normal step for TCA's libraries as they use macros or any library which uses macros.
- Run the app

# Architectural overview

I chose to use TCA as my choice of architecture due to many reasons. Those include:
- Highly scalable
- Composable (hence the name)
- Highly testable, with it's tools and way of testing is exhuastive and easier to write. Testing could even be performed on navigation at an early stage without too much trouble.
- Opinionated. Meaning there is set way of building out features to remain consistent throughout the lifetime of the app
- Single point entry system so that there is no way to change state without sending actions
- Dependency injection is handled easily using TCA or specifically the 'Dependencies' part of the library, which is in itself it's own library.

# Libraries used
- Only the TCA library

# What I would improve if more time
- Cover all unit tests for both features and integration tests
- Improved error handling 
  
