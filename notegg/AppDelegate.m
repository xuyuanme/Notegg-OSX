//
//  AppDelegate.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "AppDelegate.h"
#import "NotebookListViewController.h"
#import "NoteListViewController.h"

@interface  AppDelegate()

@property (nonatomic,strong) IBOutlet NotebookListViewController *notebookListViewController;
@property (nonatomic,strong) IBOutlet NoteListViewController *noteListViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"w7hk0g1c2pnqs8g" secret:@"otz05jdtj42mp83"];
    [DBAccountManager setSharedManager:accountManager];
    
    DBAccount *account = [accountManager linkedAccount];
    if (account) {
        if (![DBFilesystem sharedFilesystem]) {
            NSLog(@"Initialize DBFilesystem");
            [DBFilesystem setSharedFilesystem:[[DBFilesystem alloc] initWithAccount:account]];
        }
    }
    
    _notebookListViewController = [[NotebookListViewController alloc] initWithNibName:@"NotebookListViewController" bundle:nil];
    [[_notebookListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[_notebookListViewController view] setFrame:[[self notebookListView] bounds]];
    
    [self.notebookListView addSubview:[_notebookListViewController view]];
    
    _noteListViewController = [[NoteListViewController alloc] initWithNibName:@"NoteListViewController" bundle:nil];
    [[_noteListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[_noteListViewController view] setFrame:[[self noteListView] bounds]];
    
    [self.noteListView addSubview:[_noteListViewController view]];
}

- (IBAction)accountButtonClicked:(id)sender {
    DBAccount *linkedAccount = [[DBAccountManager sharedManager] linkedAccount];
    if (linkedAccount && linkedAccount.linked) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromWindow:self.window
                                     withCompletionBlock:^(DBAccount *account) {
                                         if (account) {
                                             NSLog(@"App linked successfully!");
                                             // The account is re-linked, so the shared file system needs to be reset again
                                             NSLog(@"Initialize DBFilesystem");
                                             [DBFilesystem setSharedFilesystem:[[DBFilesystem alloc] initWithAccount:account]];
                                         }
                                     }];
    }
}

- (IBAction)addButtonClicked:(id)sender {
}

- (IBAction)deleteButtonClicked:(id)sender {
}

@end
