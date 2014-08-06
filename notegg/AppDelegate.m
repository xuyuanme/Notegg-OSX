//
//  AppDelegate.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "AppDelegate.h"
#import "NotebookListViewController.h"

@interface  AppDelegate()

@property (nonatomic,strong) IBOutlet NotebookListViewController *notebookListViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"w7hk0g1c2pnqs8g" secret:@"otz05jdtj42mp83"];
    [DBAccountManager setSharedManager:accountManager];
    
    _notebookListViewController = [[NotebookListViewController alloc] initWithNibName:@"NotebookListViewController" bundle:nil];
    [[_notebookListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[_notebookListViewController view] setFrame:[[self notebookListView] bounds]];
    
    [self.notebookListView addSubview:[_notebookListViewController view]];
}

@end
