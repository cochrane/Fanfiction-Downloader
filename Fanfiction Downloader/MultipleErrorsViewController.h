//
//  MultipleErrorsViewController.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MultipleErrorsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic) IBOutlet NSTableView *tableView;

@property (nonatomic) NSArray *errors;

@end
