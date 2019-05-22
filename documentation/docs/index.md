
# Welcome

This plugin aims to provide peer to peer security. By using this plugin user can generate public and private key pairs. Public key can be sent over the network to the server so that server can encrypt response parameters using client's public key and client can decrypt that reponse using own private key and vice versa. It also has one more layer of security using AES secret key, the string will be encrypt using this key and secret key will be encrypted using public key, hence if server/client need to decrypt the string, secret key need to be decrypt using private key and string can be decrypt using decrypted secret key.

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
  
