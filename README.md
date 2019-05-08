
# react-native-rsa-encryption

## Getting started

`$ npm install react-native-rsa-encryption --save`

### Mostly automatic installation

`$ react-native link react-native-rsa-encryption`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-rsa-encryption` and add `RNRsaEncryption.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNRsaEncryption.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNRsaEncryptionPackage;` to the imports at the top of the file
  - Add `new RNRsaEncryptionPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-rsa-encryption'
  	project(':react-native-rsa-encryption').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-rsa-encryption/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-rsa-encryption')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNRsaEncryption.sln` in `node_modules/react-native-rsa-encryption/windows/RNRsaEncryption.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Rsa.Encryption.RNRsaEncryption;` to the usings at the top of the file
  - Add `new RNRsaEncryptionPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNRsaEncryption from 'react-native-rsa-encryption';

// TODO: What to do with the module?
RNRsaEncryption;
```
  