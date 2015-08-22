//
//  BREnvironment.m
//  BREnvironment
//
//  Created by Matt on 12/6/13.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BREnvironment.h"

static BREnvironment *SharedEnvironment;
static NSBundle *SharedEnvironmentBundle;
static NSMutableArray *EnvironmentProviders;

@implementation BREnvironment {
	NSDictionary *staticEnvironment;
	NSDictionary *staticLocalEnvironment;
	NSMutableDictionary *mutableEnvironment;
	NSDictionary *mergedEnvironment;
}

- (instancetype)initWithBundle:(NSBundle *)bundle {
	if ( (self = [super init]) ) {
		if ( bundle ) {
			staticEnvironment = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"Environment" ofType:@"plist"]];
			staticLocalEnvironment = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"LocalEnvironment" ofType:@"plist"]];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(userDefaultsDidChange:)
		                                             name:NSUserDefaultsDidChangeNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
	@synchronized(self)
	{
		mergedEnvironment = nil;
	}
}

- (NSDictionary *)environmentDictionary {
	NSDictionary *result = nil;
	@synchronized(self)
	{
		if ( mergedEnvironment == nil ) {
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSDictionary *userDefaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
			NSMutableDictionary *merged = [[NSMutableDictionary alloc] initWithCapacity:([staticEnvironment count]
			                                                                             + [staticLocalEnvironment count]
			                                                                             + [userDefaultsDictionary count])];
			[merged addEntriesFromDictionary:staticEnvironment];
			[merged addEntriesFromDictionary:userDefaultsDictionary];
			[merged addEntriesFromDictionary:staticLocalEnvironment];
			[merged addEntriesFromDictionary:mutableEnvironment];
			mergedEnvironment = [merged copy];
		}
		result = mergedEnvironment;
	}
	return result;
}

- (id)objectForKey:(NSString *)key {
	id value = [self environmentDictionary][key];
	for ( id<BREnvironmentProvider> provider in EnvironmentProviders ) {
		id providerValue = provider[key];
		if ( providerValue != nil ) {
			value = providerValue;
			break;
		}
	}
	return value;
}

- (NSURL *)URLForKey:(NSString *)key {
	NSString *value = [self objectForKey:key];
	return [NSURL URLWithString:value];
}

- (NSNumber *)numberForKey:(NSString *)key {
	return [self objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key {
	return [self objectForKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key {
	return [self objectForKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
	return [[self objectForKey:key] boolValue];
}

- (void)setTransientEnvironmentValue:(id)value forKey:(NSString *)key {
	@synchronized(self)
	{
		if ( mutableEnvironment == nil ) {
			mutableEnvironment = [[NSMutableDictionary alloc] initWithCapacity:4];
		}
		if ( value == nil ) {
			[mutableEnvironment removeObjectForKey:key];
		} else {
			[mutableEnvironment setValue:value forKey:key];
		}
		mergedEnvironment = nil;
	}
}

#pragma mark - KVC

- (void)setValue:(id)value forKey:(NSString *)key {
	[self setTransientEnvironmentValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
	return [self objectForKey:key];
}

- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
	[self setTransientEnvironmentValue:obj forKey:(NSString *)key];
}

#pragma mark - Shared Environment

+ (NSBundle *)sharedEnvironmentBundle {
	return (SharedEnvironmentBundle != nil ? SharedEnvironmentBundle : [NSBundle mainBundle]);
}

+ (void)setSharedEnvironmentBundle:(NSBundle *)bundle {
	SharedEnvironmentBundle = bundle;
}

+ (instancetype)sharedEnvironment {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    SharedEnvironment = [[BREnvironment alloc] initWithBundle:[BREnvironment sharedEnvironmentBundle]];
	});
	return SharedEnvironment;
}

+ (void)registerEnvironmentProvider:(id<BREnvironmentProvider>)provider {
	if ( provider == nil ) {
		return;
	}
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		EnvironmentProviders = [[NSMutableArray alloc] initWithCapacity:4];
	});
	[EnvironmentProviders addObject:provider];
}

+ (void)unregisterEnvironmentProvider:(id<BREnvironmentProvider>)provider {
	if ( provider ) {
		[EnvironmentProviders removeObjectIdenticalTo:provider];
	}
}

+ (NSDictionary *)environmentDictionaryWithBundle:(NSBundle *)bundle {
	[self setSharedEnvironmentBundle:bundle];
	return [self environmentDictionary];
}

+ (void)saveEnvironmentValue:(id)value forKey:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+ (NSDictionary *)environmentDictionary {
	return [[self sharedEnvironment] environmentDictionary];
}

+ (BOOL)isUnitTest {
	// NOTE: preprocessor macros don't work to tell if running as a unit test, because the normal app target is
	//       compiled as a dependent project, then the unit test target is compiled. Thus the unit test
	//       scheme must add a UNITTEST environment variable for this to work.
	return [[[NSProcessInfo processInfo] environment][@"UNITTEST"] isEqualToString:@"1"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	BREnvironment *env = [(BREnvironment *)[[self class] allocWithZone:zone] initWithBundle:nil];
	env->staticEnvironment = staticEnvironment;
	env->staticLocalEnvironment = staticLocalEnvironment;
	env->mergedEnvironment = mergedEnvironment;
	env->mutableEnvironment = [mutableEnvironment mutableCopy];
	return env;
}

@end
