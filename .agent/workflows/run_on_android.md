---
description: How to run the app on an Android Emulator
---

# Run on Android Emulator

1.  **List available emulators:**
    ```bash
    flutter emulators
    ```

2.  **Launch an emulator:**
    Replace `<emulator_id>` with the ID from the previous step (e.g., `Medium_Phone_API_36.1`).
    ```bash
    flutter emulators --launch <emulator_id>
    ```

3.  **Run the app:**
    Once the emulator is running, execute:
    ```bash
    flutter run -d emulator-5554
    ```
    *(Note: `emulator-5554` is the default ID for the first running emulator. Check `flutter devices` if unsure.)*
