Keychain-34018
==============

This project is only intended to help track down error -34018 when accessing the keychain on iOS 8 from within a UIApplicationDidBecomeActiveNotification handler.

__Steps to Reproduce:__

1. Run the attached Keychain34018 app from Xcode (using 6.1 here) on an iPad Air - the simulator was not used.
2. Tap the Update button in the upper right corner.
3. Switch away from the app with the home button.
4. Run some other apps, such as Mail (with a fairly populated inbox), Safari (refresh multiple tabs with heavy content), maybe open a game.
5. Switch back to the Keychain34018 app.
6. If you don't get error -34018, stop the app from Xcode and restart at step 1.

It is not clear what is causing the error, but memory pressure appears to be a factor. This sample intentionally loads up some memory-hungry objects to help cause pressure.

This project contains a custom copy of [JNKeychain](https://github.com/jeremangnr/JNKeychain) to expose errors.
