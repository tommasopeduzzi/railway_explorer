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

## Reflektion
Unserer Meinung nach haben wir uns mit diesem Projekt selber übertroffen: Das Ziel war hoch gesteckt und trotzdem haben wir die Ziele und noch mehr erreicht.

Für eine kleine Gruppe an Menschen ist die App sehr hilfreich. Die App hat daher einen echten Nutzen. Daher planen wir die App so bald wie möglich auf dem Google Play Store für die Öffentlichkeit einfach zu veröffentlichen. Ausserdem ist die App open source, was es der Community erlaubt sie zu verbessern.

Schwierigkeiten wie die mangelnde Dokumention zu Flutter und den Packages konnten wir gut überwinden. Auch wenn einer des Teams nicht verfügbar war konnten wir durch gute Absprechung und der Versionskontrolle auf GitHub reibungslos weiterarbeiten. Der schwierigste Teil der Arbeit war es die Routen abzuspeichern, was wir in einer nicht besonders effizienten aber einfachen weg mithilfe von JSON gelöst haben.