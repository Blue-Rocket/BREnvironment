//
//  ExampleEnvironmentProvider.m
//  BREnvironment
//
//  Created by Matt on 12/10/14.
//  Copyright (c) 2014 Blue Rocket, Inc. All rights reserved.
//

#import "ExampleEnvironmentProvider.h"

@implementation ExampleEnvironmentProvider

- (id)objectForKeyedSubscript:(id)key {
	return ([key isEqualToString:@"Magic"] ? @"Act" : nil);
}

@end
