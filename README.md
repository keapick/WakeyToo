# WakeyToo
A Wake-on-LAN utilty for Apple platforms.

iOS, tvOS and macOS versions are available on the Apple App Store. 
End user docs are available at https://ieesizaq.com/wakeytoo/

This is the open source repo for developers who are interested in contributing or building it themselves.

## Developer Guide
I wrote WakeyToo to practice Swift and meet my own need for a Wake-on-LAN utility.

You will need to request a multicast entitlement to do UDP broadcasts. Remember to change the bundle ids!
https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.multicast

Version 1.1.0 and before were built from my private monorepo, which contains a lot of unrelated code. 
Future releases will be built from this repo.

### WakeyLib
A swift package that contains core functionality.

### Apps
Wakey, is the iOS, iPad and tvOS app.
WakeyToo, is the macOS app.

On the App Store, all binaries are bundled together and branded as WakeyToo.
