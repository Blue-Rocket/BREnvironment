//
//  BREnvironment.h
//  BREnvironment
//
//  Created by Matt on 12/6/13.
//  Copyright (c) 2013 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BREnvironment : NSObject

// get all environment values as a dictionary
- (NSDictionary *)environmentDictionary;

// convenience methods to extract values from the environment dictionary as specific types
- (NSURL *)URLForKey:(NSString *)key;
- (NSNumber*)numberForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray*)arrayForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

// set a dynamic environment value for the given key; if value is nil the key will be removed;
// this value is NOT persisted across app restarts
- (void)setTransientEnvironmentValue:(id)value forKey:(NSString *)key;

// persist an environment value, e.g. a service URL; the value will be persisted across app restarts
+ (void)saveEnvironmentValue:(id)value forKey:(NSString *)key;

// return YES if UNITTEST environment flag present
+ (BOOL)isUnitTest;

#pragma mark - Shared environment

// get the bundle used by the shared environment
+ (NSBundle *)sharedEnvironmentBundle;

// set the bundle used by the shared environment; only works before the shared environment is created
+ (void)setSharedEnvironmentBundle:(NSBundle *)bundle;

// get a singleton shared environment; the object is instantiated the first time the method is called
+ (instancetype)sharedEnvironment;

#pragma mark - Shared environment convenience methods

+ (NSDictionary *)environmentDictionary;
+ (NSDictionary *)environmentDictionaryWithBundle:(NSBundle *)bundle;

#pragma mark - ObjC literal syntax

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

@end
