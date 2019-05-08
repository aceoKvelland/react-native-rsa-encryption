
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import android.util.Base64;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.nio.charset.Charset;
import java.security.*;
import java.security.spec.*;

public class RNRsaEncryptionModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private static String privateKeyString = "";

  public RNRsaEncryptionModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNRsaEncryption";
  }

  @ReactMethod
  public static void generateKeyPair(Callback successCallback, Callback errorCallback) {
    try {
      // 1. generate public key and private key
      KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
      keyPairGenerator.initialize(1024); // key length
      KeyPair keyPair = keyPairGenerator.genKeyPair();
      privateKeyString = Base64.encodeToString(keyPair.getPrivate().getEncoded(), Base64.DEFAULT);
      String publicKeyString = Base64.encodeToString(keyPair.getPublic().getEncoded(), Base64.DEFAULT);
      WritableMap resultData = Arguments.createMap();
      resultData.putString("encodedPublicKey", publicKeyString);
      successCallback.invoke(resultData);
    } catch (java.lang.Exception e) {
      errorCallback.invoke(e.getMessage());
    }
  }

  @ReactMethod
  public void encryptString(String text, String publicKeyString,Callback successCallback, Callback errorCallback) {

    try {
      // 1. generate secret key using AES
      KeyGenerator keyGenerator = KeyGenerator.getInstance("AES");
      keyGenerator.init(128);
      SecretKey secretKey = keyGenerator.generateKey();
      // 2. encrypt string using secret key
      byte[] raw = secretKey.getEncoded();
      SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
      Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
      cipher.init(Cipher.ENCRYPT_MODE, skeySpec, new IvParameterSpec(new byte[16]));
      String cipherTextString = Base64.encodeToString(cipher.doFinal(text.getBytes(Charset.forName("UTF-8"))), Base64.DEFAULT);
      // 3. get public key
      X509EncodedKeySpec publicSpec = new X509EncodedKeySpec(Base64.decode(publicKeyString, Base64.DEFAULT));
      KeyFactory keyFactory = KeyFactory.getInstance("RSA");
      PublicKey publicKey = keyFactory.generatePublic(publicSpec);
      // 4. encrypt secret key using public key
      Cipher cipher2 = Cipher.getInstance("RSA/ECB/OAEPWithSHA1AndMGF1Padding");
      cipher2.init(Cipher.ENCRYPT_MODE, publicKey);
      String encryptedSecretKey = Base64.encodeToString(cipher2.doFinal(secretKey.getEncoded()), Base64.DEFAULT);
      WritableMap resultData = Arguments.createMap();
      resultData.putString("cipherTextString", cipherTextString);
      resultData.putString("encryptedSecretKey", encryptedSecretKey);
      successCallback.invoke(resultData);
    } catch (java.lang.Exception e) {
      errorCallback.invoke(e.getMessage());
    }

  }

  @ReactMethod
  public void decryptString(String cipherTextString, String encryptedSecretKey,Callback successCallback, Callback errorCallback) {

    try {
      // 1. Get private key
      PKCS8EncodedKeySpec privateSpec = new PKCS8EncodedKeySpec(Base64.decode(privateKeyString, Base64.DEFAULT));
      KeyFactory keyFactory = KeyFactory.getInstance("RSA");
      PrivateKey privateKey = keyFactory.generatePrivate(privateSpec);

      // 2. Decrypt encrypted secret key using private key
      Cipher cipher1 = Cipher.getInstance("RSA/ECB/OAEPWithSHA1AndMGF1Padding");
      cipher1.init(Cipher.DECRYPT_MODE, privateKey);
      byte[] secretKeyBytes = cipher1.doFinal(Base64.decode(encryptedSecretKey, Base64.DEFAULT));
      SecretKey secretKey = new SecretKeySpec(secretKeyBytes, 0, secretKeyBytes.length, "AES");

      // 3. Decrypt encrypted text using secret key
      byte[] raw = secretKey.getEncoded();
      SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
      Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
      cipher.init(Cipher.DECRYPT_MODE, skeySpec, new IvParameterSpec(new byte[16]));
      byte[] original = cipher.doFinal(Base64.decode(cipherTextString, Base64.DEFAULT));
      String text = new String(original, Charset.forName("UTF-8"));
      WritableMap resultData = Arguments.createMap();
      resultData.putString("decryptedString", text);
      successCallback.invoke(resultData);
    } catch (java.lang.Exception e) {
      errorCallback.invoke(e.getMessage());
    }

  }
}