//
//  BREnvironment.h
//  BREnvironment
//
//  Created by Matt on 12/6/13.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/**
 An object that can be queried for environment values. These can be registered with @c BREnvironment
 to allow extending where environment values come from.
 */
@protocol BREnvironmentProvider <NSObject>

/**
 Get an environment value for a given key.
 
 @param key The key to get the associated environment value for.
 @return The object, or @c nil if not available.
 */
- (id)objectForKeyedSubscript:(id)key;

@end

/// Helper class for supporting environment-specific settings during development.
///
/// The general idea is to include an `Environment.plist` file in your project that contains
/// basic default production environment settings for your app, such as a base URL to connect to
/// for some web service. During development, if you'd like to use some other web service
/// server, you include a `LocalEnvironment.plist` in your build that overrides the default
/// production settings. The `LocalEnvironment.plist` file should *not* be added to any source
/// control system.
///
/// To access the environment settings, this class provides helper getter methods like:
///
///    BREnvironment env = [BREnvironment sharedEnvironment];
///    NSURL *serviceURL = [env URLForKey:@"baseURL"];
///    BOOL sassy = [env boolForKey:@"talkBack"];
///
/// You can also access the entire environment as a dictionary with a single line:
///
///    NSDictionary *env = [BREnvironment environmentDictionary];
///
/// BREnvironment also acts as a proxy for `NSUserDefaults`. All values available via
///
///    [NSUserDefaults standardUserDefaults];
///
/// are also available via any of the accessors in this class. You can save a value
/// into `NSUserDefaults` using the `saveEnvironmentValue:forKey:` method.
@interface BREnvironment : NSObject

///
/// @name Accessors
///

/**
 * Get all environment values as a dictionary.
 *
 * @return a dictionary of all available environment settings
 */
- (NSDictionary *)environmentDictionary;

/**
 * Convenience method to extract a `NSURL` from an environment setting.
 *
 * The setting value is assumed to be a `NSString`.
 *
 * @param key the setting to get
 * @return the setting value as a `NSURL`
 */
- (NSURL *)URLForKey:(NSString *)key;

/**
 * Convenience method to extract a `NSNumber` from an environment setting.
 *
 * The setting value is assumed to be a `NSNumber` already, this simply
 * casts the value.
 *
 * @param key the setting to get
 * @return the setting value as a `NSNumber`
 */
- (NSNumber *)numberForKey:(NSString *)key;

/**
 * Convenience method to extract a `NSString` from an environment setting.
 *
 * The setting value is assumed to be a `NSString` already, this simply
 * casts the value.
 *
 * @param key the setting to get
 * @return the setting value as a `NSString`
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 * Convenience method to extract a `NSArray` from an environment setting.
 *
 * The setting value is assumed to be a `NSArray` already, this simply
 * casts the value.
 *
 * @param key the setting to get
 * @return the setting value as a `NSArray`
 */
- (NSArray *)arrayForKey:(NSString *)key;

/**
 * Convenience method to extract a `BOOL` from an environment setting.
 *
 * The setting value is assumed to be a `NSNumber`.
 *
 * @param key the setting to get
 * @return the setting value as a `BOOL`
 */
- (BOOL)boolForKey:(NSString *)key;

#pragma mark - ObjC literal syntax

/// Support modern Objective-C literal getter syntax to query environment settings.
///
/// This method allows you to access values from the environment like this:
///
///    NSString *foo = [BREnvironment sharedEnvironment][@"foo"];
///
/// @param key the setting to get
/// @return the setting value
- (id)objectForKeyedSubscript:(id)key;


/**
 * Support modern Objective-C literal setter syntax to set transient environment settings.
 *
 * This method allows you to set a *transient* value into the environment like this:
 *
 *     NSString *foo = [BREnvironment sharedEnvironment][@"foo"];
 *
 * @param key the name of the setting to set
 * @param obj the value of the setting
 * @sees etTransientEnvironmentValue:forKey:
 */
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

///
/// @name Updating environment values
///

/**
 * Set a dynamic environment value.
 *
 * This value is **not** persisted across app restarts. If `value` is `nil` the key will be removed
 * from the environment.
 *
 * @param value the value to set for the associated `key`
 * @param key the key to use
 */
- (void)setTransientEnvironmentValue:(id)value forKey:(NSString *)key;

/**
 * Persist an environment value.
 *
 * This value **is** persisted across app restarts by saving the value into `NSUserDefaults`.
 * If `value` is `nil` the key will be removed from the environment.
 *
 * @param value the value to set for the associated `key`
 * @param key the key to use
 */
+ (void)saveEnvironmentValue:(id)value forKey:(NSString *)key;

#pragma mark - Shared environment

///
/// @name Shared environment
///

/**
 * Get the bundle used by the shared environment.
 *
 * @return the bundle
 */
+ (NSBundle *)sharedEnvironmentBundle;

/**
 * Set the bundle used by the shared environment.
 *
 * This only works before the shared environment is created for the first time, so should be
 * called early on in the application's life.
 *
 * @param bundle the bundle to use for the shared environment
 */
+ (void)setSharedEnvironmentBundle:(NSBundle *)bundle;

/**
 * Get a singleton shared environment instance.
 *
 * The object is instantiated the first time the method is called, and will use the
 * `[NSBundle mainBundle]` unless a different bundle has been passed to
 * `setSharedEnvironmentBundle:` before this is called the first time.
 *
 * @return the singleton environment instance
 */
+ (instancetype)sharedEnvironment;

/**
 * Register a @c BREnvironmentProvider for all @c BREnvironment instances to use.
 *
 * @param provider The provider to register.
 */
+ (void)registerEnvironmentProvider:(id<BREnvironmentProvider>)provider;

/**
 * Unregister a @c BREnvironmentProvider for all @c BREnvironment instances to use.
 *
 * @param provider The provider to register.
 */
+ (void)unregisterEnvironmentProvider:(id<BREnvironmentProvider>)provider;

#pragma mark - Shared environment convenience methods

+ (NSDictionary *)environmentDictionary;
+ (NSDictionary *)environmentDictionaryWithBundle:(NSBundle *)bundle;

#pragma mark - Utilities

/// @name Other utilities

/**
 * Test if a `UNITTEST` environment flag is present.
 *
 * This will check the `NSProcessInfo` environment for a flag named `UNITTEST`. This can be useful
 * for disabling normal application startup routines when running as an automated test.
 *
 * @return `YES` if a `UNITTEST` environment variable is set
 */
+ (BOOL)isUnitTest;


@end
