//
//  AppDelegate.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "AppDelegate.h"
#import "NotebookListViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NotebookListViewController *notebookListViewController = [[NotebookListViewController alloc] initWithNibName:@"NotebookListViewController" bundle:nil];
    [[notebookListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[notebookListViewController view] setFrame:[[self notebookListView] bounds]];
    
    [self.notebookListView addSubview:[notebookListViewController view]];
}

@end
