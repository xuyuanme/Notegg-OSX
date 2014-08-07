//
//  AppDelegate.h
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSOutlineView *notebookListView;
@property (weak) IBOutlet NSOutlineView *noteListView;
@property (weak) IBOutlet NSView *noteContentView;

@property (weak) IBOutlet NSButton *accountButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *deleteButton;

@end
