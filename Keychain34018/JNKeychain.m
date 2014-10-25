//
//  JNKeychain.m
//
//  Created by Jeremias Nunez on 5/10/13.
//  Copyright (c) 2013 Jeremias Nunez. All rights reserved.
//
//  jeremias.np@gmail.com

#import "JNKeychain.h"

@interface JNKeychain ()

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key;

@end

@implementation JNKeychain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key
{
  // see http://developer.apple.com/library/ios/#DOCUMENTATION/Security/Reference/keychainservices/Reference/reference.html
  return [NSMutableDictionary dictionaryWithObjectsAndKeys:
          (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
          key, (__bridge id)kSecAttrService,
          key, (__bridge id)kSecAttrAccount,
          (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
          nil];
}

+ (id)saveValue:(id)data forKey:(NSString*)key
{
	NSString *value = nil;

  NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
  // delete any previous value with this key
  OSStatus deleteStatus = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
  if (deleteStatus != noErr) {
    value = [NSString stringWithFormat:@"Error deleting value: %d", (int)deleteStatus];
		return value;
	}

  [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];

  OSStatus addStatus = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
  if (addStatus != noErr) {
    value = [NSString stringWithFormat:@"Error adding value: %d", (int)addStatus];
		return value;
	}

	return nil;
}

+ (id)loadValueForKey:(NSString *)key
{
  id value = nil;
  NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
  CFDataRef keyData = NULL;

  [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
  [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData);
  if (status == noErr) {
    @try {
      value = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
    }
    @catch (NSException *e) {
      NSLog(@"Unarchive of %@ failed: %@", key, e);
    }
    @finally {}
  }
  else {
    value = [NSString stringWithFormat:@"Error loading value: %d", (int)status];
  }

  if (keyData) {
    CFRelease(keyData);
  }

  return value;
}

+ (void)deleteValueForKey:(NSString *)key
{
  NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
  SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end