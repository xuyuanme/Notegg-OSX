//
//  AppDelegate.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "AppDelegate.h"

@interface  AppDelegate()

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
        [_accountButton setHidden:true];
    }
    
    [self setNotebookListViewController:[[NotebookListViewController alloc] initWithNibName:@"NotebookListViewController" bundle:nil]];
}

- (void)setNotebookListViewController:(NotebookListViewController *)notebookListViewController {
    _notebookListViewController = notebookListViewController;
    [self setController:_notebookListViewController withView:_notebookListView];
}

- (void)setNoteListViewController:(NoteListViewController *)noteListViewController {
    _noteListViewController = noteListViewController;
    [self setController:_noteListViewController withView:_noteListView];
}

- (void)setNoteController:(NoteController *)noteController {
    _noteController = noteController;
    [self setController:_noteController withView:_noteContentView];
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
                                             [_accountButton setHidden:true];
                                         }
                                     }];
    }
}

- (IBAction)addButtonClicked:(id)sender {
}

- (IBAction)deleteButtonClicked:(id)sender {
}

# pragma mark private methods

- (void) setController:(NSViewController *)controller withView:(NSView *)view {
    if (controller) {
        [[controller view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        [[controller view] setFrame:[view bounds]];
        [view setSubviews:@[[controller view]]];
    } else {
        [view setSubviews:@[]];
    }
}

@end
