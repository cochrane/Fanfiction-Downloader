//
//  ErrorTableCellView.h
//  Fanfiction Downloader
//
//  Created by Torsten Kammer on 19.02.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ErrorTableCellView : NSTableCellView

@property (nonatomic) IBOutlet NSTextField *storyNameField;
@property (nonatomic) IBOutlet NSTextField *descriptionField;
@property (nonatomic) IBOutlet NSTextField *recoverySuggestionField;

@end
