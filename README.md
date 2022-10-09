# Railway Explorer
This app is designed to track your rail journeys. It was made for a school project.
**It only works on android!!** 

## Running
1. Run the following command:
```
$ flutter pub get
```
2. Change line 203 in `*directory to your pub packages*/background_location-0.8.1/android/src/main/kotlin/com/almoullim/background_location/BackgroundLocationService.kt` from 
```kotlin
override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
```

to

```kotlin
override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {

```

3. Run the following command:
```
$ flutter run
```

4. Make sure that all necessary permissions (always location on and all optimizations off) are set correctly and restart the app if necessary. You can find a button to the permission settings in the settings.