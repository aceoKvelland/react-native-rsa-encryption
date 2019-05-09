
# react-native-rsa-encryption

## Getting started

`$ npm install @akeo/react-native-rsa-encryption --save`

### Mostly automatic installation

`$ react-native link @akeo/react-native-rsa-encryption`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `@akeo/react-native-rsa-encryption` and add `RNRsaEncryption.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNRsaEncryption.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNRsaEncryptionPackage;` to the imports at the top of the file
  - Add `new RNRsaEncryptionPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':@akeo_react-native-rsa-encryption'
  	project(':@akeo_react-native-rsa-encryption').projectDir = new File(rootProject.projectDir, 	'../node_modules/@akeo/react-native-rsa-encryption/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':@akeo_react-native-rsa-encryption')
  	```

## Usage
```javascript
import RNRsaEncryption from '@akeo/react-native-rsa-encryption';

// To generate key pairs, (it will return public key in base64 encoded format)
RNRsaEncryption.generateKeyPair((response) => {
	console.log(response);
}, (error) => {
	console.log(error);
});

// To encrypt a string, (it will return encrypted string with public key encrypted aes secret key)
RNRsaEncryption.encryptString("string to be encrypt", "public key base 64 encoded format",(response) => {
	console.log(response);
}, (error) => {
	console.log(error);
});

// To decrypt a string, (it will return decrypted string)
RNRsaEncryption.decryptString("encrypted string", "encrypted secret key",(response) => {
	console.log(response);
}, (error) => {
	console.log(error);
});
```
  
