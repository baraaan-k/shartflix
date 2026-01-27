<p align="center">
  <img src="./ScreenShots.png" width="950" alt="Shartflix Screenshots" />
</p>

# Shartflix — Flutter Case Study

Shartflix is a Flutter movie browsing app built as a case study project.  
It delivers a clean movie list experience with pagination, a movie detail flow, and a favorites (like/unlike) interaction.  
On top of the core requirements, the project includes several bonus implementations such as Firebase (Analytics + Crashlytics), light/dark theme, centralized navigation, a logger service, Lottie animation, localization (TR/EN), and branded splash/app icon.

The case PDF is included in the repository.

---

## What You Can Do in the App

- Browse movies in a paginated list
- Open movie details in a sheet-style flow
- Like / Unlike movies (favorites)

---

## Bonus Features Included

### Firebase (Analytics + Crashlytics)
- Firebase initializes on app start
- Crashlytics is wired to catch:
  - Flutter framework errors
  - Platform/async errors

### Localization (TR / EN)
- Localized UI via `arb` files
- Generated with `flutter gen-l10n`

### Light / Dark Theme
- Full light/dark support with consistent styling

### Centralized Navigation (Navigation Service)
- Central routing setup (go_router)
- Navigation handled in a single, consistent place

### Logger Service
- App-level logger with levels (debug/info/warn/error) and tags
- Used for cleaner diagnostics instead of scattered prints

### Lottie Animation
- Like/Unlike triggers a center-screen Lottie burst
- Plays once and disappears automatically

### Splash Screen + App Icon
- Branded app icon
- Branded splash screen

---

## Run Locally

```bash
flutter pub get
flutter gen-l10n
flutter run
