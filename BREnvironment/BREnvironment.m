//
//  BREnvironment.m
//  BREnvironment
//
//  Created by Matt on 12/6/13.
//  Copyright (c) 2013 Blue Rocket, Inc. All rights reserved.
//

#import "BREnvironment.h"

static BREnvironment *SharedEnvironment;
static NSBundle *SharedEnvironmentBundle;

@implementation BREnvironment {
	NSDictionary *staticEnvironment;
	NSDictionary *staticLocalEnvironment;
	NSMutableDictionary *mutableEnvironment;
	NSDictionary *mergedEnvironment;
}

- (instancetype)initWithBundle:(NSBundle *)bundle {
	if ((self = [super init])) {
		staticEnvironment = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"Environment" ofType:@"plist"]];
		staticLocalEnvironment = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"LocalEnvironment" ofType:@"plist"]];
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
		if (mergedEnvironment == nil) {
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

- (NSURL *)URLForKey:(NSString *)key {
	NSString *value = [self environmentDictionary][key];
	return [NSURL URLWithString:value];
}

- (NSNumber *)numberForKey:(NSString *)key {
	NSNumber *value = (NSNumber *)[self environmentDictionary][key];
	return value;
}

- (NSString *)stringForKey:(NSString *)key {
	return [self environmentDictionary][key];
}

- (NSArray *)arrayForKey:(NSString *)key {
	return [self environmentDictionary][key];
}

- (BOOL)boolForKey:(NSString *)key {
	return [[self environmentDictionary][key] boolValue];
}

- (void)setTransientEnvironmentValue:(id)value forKey:(NSString *)key {
	@synchronized(self)
	{
		if (mutableEnvironment == nil) {
			mutableEnvironment = [[NSMutableDictionary alloc] initWithCapacity:4];
		}
		if (value == nil) {
			[mutableEnvironment removeObjectForKey:key];
		}
		else {
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
	return [self environmentDictionary][key];
}

- (id)objectForKeyedSubscript:(id)key {
	return [self environmentDictionary][key];
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

@end
