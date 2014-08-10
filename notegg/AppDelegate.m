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

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag){
        [[self window] makeKeyAndOrderFront:self];
    }
    return YES;
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
    NotesNode *notebookNode = [[_notebookListViewController outlineView] itemAtRow:[[_notebookListViewController outlineView] selectedRow]];
    NSLog(@"Selected notebook %@", [notebookNode name]);
    
    if (notebookNode) {
        [notebookNode addChild];
    } else {
        [self promptAndCreateNotebook:[DBPath root] inFilesystem:[DBFilesystem sharedFilesystem]];
    }
}

- (IBAction)deleteButtonClicked:(id)sender {
    NotesNode *notebookNode = [[_notebookListViewController outlineView] itemAtRow:[[_notebookListViewController outlineView] selectedRow]];
    NotesNode *noteNode = [[_noteListViewController outlineView] itemAtRow:[[_noteListViewController outlineView] selectedRow]];
    NSLog(@"Selected notebook and note: %@, %@", [notebookNode name], [noteNode name]);

    if (noteNode) {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"%@%@%@", @"Delete the note ", noteNode.name, @"?"]
                                         defaultButton:@"OK" alternateButton:@"Cancel"
                                           otherButton:nil informativeTextWithFormat:
                          @"Deleted note can be restored in Dropbox website"];
        
        if ([alert runModal] == NSAlertDefaultReturn) {
            // OK clicked, delete the record
            [noteNode remove];
        }
    } else if (notebookNode) {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"%@%@%@", @"Delete the notebook ", notebookNode.name, @"?"]
                                         defaultButton:@"OK" alternateButton:@"Cancel"
                                           otherButton:nil informativeTextWithFormat:
                          @"Deleted notebook can be restored in Dropbox website"];
        
        if ([alert runModal] == NSAlertDefaultReturn) {
            // OK clicked, delete the record
            [notebookNode remove];
        }
    }
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

- (void)promptAndCreateNotebook:(DBPath *)parentPath inFilesystem:(DBFilesystem *)filesystem {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter name:"
                                     defaultButton:@"Create new notebook"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [alert setAccessoryView:input];
    NSInteger ret = [alert runModal];
    if (ret == NSAlertDefaultReturn) {
        if ([[input stringValue] length]) {
            [filesystem createFolder:[parentPath childPath:[input stringValue]] error:nil];
        }
    }
}

@end
