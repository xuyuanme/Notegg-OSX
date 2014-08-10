//
//  AppDelegate.h
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotebookListViewController.h"
#import "NoteListViewController.h"
#import "NoteController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *notebookListView;
@property (weak) IBOutlet NSView *noteListView;
@property (weak) IBOutlet NSView *noteContentView;

@property (nonatomic,strong) IBOutlet NotebookListViewController *notebookListViewController;
@property (nonatomic,strong) IBOutlet NoteListViewController *noteListViewController;
@property (nonatomic, retain) NoteController *noteController;

@property (weak) IBOutlet NSButton *accountButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *deleteButton;

@end
