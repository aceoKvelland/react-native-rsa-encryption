#import "RNRsaEncryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import <React/RCTLog.h>

@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof( keyPtr ) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted );
    
    if( cryptStatus == kCCSuccess )
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free( buffer ); //free the buffer
    return nil;
}

@end

@implementation RNRsaEncryption

SecKeyRef publicKey = NULL;
SecKeyRef privateKey = NULL;
NSString *publicTagString = @"com.RNRsaEncryption.publickey";
NSString *privateTagString = @"com.RNRsaEncryption.privatekey";

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(generateKeyPair:(RCTResponseSenderBlock)callback :(RCTResponseSenderBlock)errCallback)
{
    NSData *publicTag = [publicTagString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateTag = [privateTagString dataUsingEncoding:NSUTF8StringEncoding];
    
	NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init]; 

	[keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
	forKey:(__bridge id)kSecAttrKeyType];
	[keyPairAttr setObject:[NSNumber numberWithInt:1024]
	forKey:(__bridge id)kSecAttrKeySizeInBits];
	
	[privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
	
	[publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
	
	[keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs]; 
	[keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs]; 
	
	OSStatus err = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    
    //Convert public key in NSData Type
//    size_t  publicKeySize = SecKeyGetBlockSize(publicKey);
//    NSData  *publicTag1 = [NSData dataWithBytes:publicKey length:publicKeySize];
    CFErrorRef error = NULL;
    NSData* publicTag1 = (NSData*)CFBridgingRelease(  // ARC takes ownership
                                                 SecKeyCopyExternalRepresentation(publicKey, &error)
                                                 );
    if (!publicTag1) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
    } else {
        NSString *publicEncodeKey = [publicTag1 base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSDictionary *result = @{@"encodedPublicKey" : publicEncodeKey};
        CFRelease(publicKey);
        callback(@[result]);
    }


    
}

RCT_EXPORT_METHOD(encryptString:(NSString *)text :(NSString *)publicKeyString :(RCTResponseSenderBlock)callback :(RCTResponseSenderBlock)errCallback)
{
    // get AES secret key
    NSData* secretKey = [self random128BitAESKey];
    // encrypt string using secret key
    NSString* secretEncodeKey = [secretKey base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSData *encryptedString = [[text dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:secretEncodeKey];
    NSString *encryptedStringUsingKey = [encryptedString base64EncodedStringWithOptions:kNilOptions];
    // get public key
    NSData *decodedPublicKey = [[NSData alloc] initWithBase64EncodedString:publicKeyString options:0];
    SecKeyRef publicKey = [self secKeyRefFromPublicKeyData:(NSData *)decodedPublicKey];
    // encryot secret key using public key
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA1AESGCM;
    BOOL canEncrypt = SecKeyIsAlgorithmSupported(publicKey,
                                                 kSecKeyOperationTypeEncrypt,
                                                 algorithm);
    NSData* cipherText = nil;
    NSData* plainText=[secretEncodeKey dataUsingEncoding:NSUTF8StringEncoding];
    if (canEncrypt) {
        CFErrorRef error = NULL;
        cipherText = (NSData*)CFBridgingRelease(      // ARC takes ownership
                                                SecKeyCreateEncryptedData(publicKey,
                                                                          algorithm,
                                                                          (__bridge CFDataRef)plainText,
                                                                          &error));
        if (!cipherText) {
            NSError *err = CFBridgingRelease(error);  // ARC takes ownership
            // Handle the error. . .
        } else {
            NSString *encodedEncryptedSecretKey = [cipherText base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
            NSDictionary *result = @{@"cipherTextString" : encryptedStringUsingKey, @"encryptedSecretKey" : encodedEncryptedSecretKey};
            if (publicKey) { CFRelease(publicKey); }
            callback(@[result]);
        }
    }
    
}

RCT_EXPORT_METHOD(decryptString:(NSString *)cipherTextString :(NSString *)encryptedSecretKey :(RCTResponseSenderBlock)callback :(RCTResponseSenderBlock)errCallback)
{
     // get private key
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA1AESGCM;
    BOOL canDecrypt = SecKeyIsAlgorithmSupported(privateKey,
                                                 kSecKeyOperationTypeDecrypt,
                                                 algorithm);
    NSData* decryptedSecretKey = nil;
    NSData *decodedSecretKey = [[NSData alloc] initWithBase64EncodedString:encryptedSecretKey options:0];
    if (canDecrypt) {
        CFErrorRef error = NULL;
        decryptedSecretKey = (NSData*)CFBridgingRelease(       // ARC takes ownership
                                               SecKeyCreateDecryptedData(privateKey,
                                                                         algorithm,
                                                                         (__bridge CFDataRef)decodedSecretKey,
                                                                         &error));
        if (!decryptedSecretKey) {
            NSError *err = CFBridgingRelease(error);  // ARC takes ownership
            // Handle the error. . .
        } else {
            NSString * secretEncodeKey =[[NSString alloc] initWithData:decryptedSecretKey encoding:NSUTF8StringEncoding];
            // decrypt secret key using private key
            NSData *decodedCipherText = [[NSData alloc] initWithBase64EncodedString:cipherTextString options:kNilOptions];
            NSData *decryptedString = [decodedCipherText AES256DecryptWithKey:secretEncodeKey];
            NSString *decryptedCipherText = [[NSString alloc] initWithData:decryptedString encoding:NSUTF8StringEncoding];
            NSDictionary *result = @{@"decryptedString" : decryptedCipherText};
            callback(@[result]);
        }
    }
}

- (NSData *)random128BitAESKey {
    unsigned char buf[128];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

- (SecKeyRef)secKeyRefFromPublicKeyData:(NSData *)publicKeyData
{
    NSDictionary* options = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                              (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
                              (id)kSecAttrKeySizeInBits: @1024,
                              };
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)publicKeyData,
                                         (__bridge CFDictionaryRef)options,
                                         &error);
    if (!key) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
        return false;
    } else {
        return key;
    }
}


@end
