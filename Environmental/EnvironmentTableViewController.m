//
//  EnvironmentTableViewController.m
//  BREnvironment
//
//  Created by Matt on 4/29/14.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "EnvironmentTableViewController.h"
#import "BREnvironment.h"

static NSString * const kCellIdentifier = @"Cell";

@implementation EnvironmentTableViewController {
	NSDictionary *model;
	NSArray *keys;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	model = [BREnvironment environmentDictionary];
	keys = [[model allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
	NSString *key = keys[indexPath.row];
	id val = model[keys[indexPath.row]];
	cell.textLabel.text = key;
	cell.detailTextLabel.text = [val description];
    
    return cell;
}

@end
