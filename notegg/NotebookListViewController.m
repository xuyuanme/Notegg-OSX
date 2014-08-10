//
//  NotebookListViewController.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "NotebookListViewController.h"
#import "AppDelegate.h"

@interface NotebookListViewController ()

@end

@implementation NotebookListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setRoot:[NotesNode rootNode:nil WithDelegate:self]];
        [[self outlineView] reloadData];
    }
    return self;
}

-(void)awakeFromNib {
    [[self outlineView] registerForDraggedTypes:@[@"me.xuyuan.notegg.notes.node"]];
}

# pragma mark - NSOutlineViewDelegate - Selection

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    AppDelegate *app = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NotesNode *node = [self nodeFromItem:[[self outlineView] itemAtRow:[[self outlineView] selectedRow]]];
    if ([[node className] isEqualToString:@"NotesAccountNode"]) {
        // If the folder is renamed, close other views, so they can be reopened manually
        [app setNoteListViewController:nil];
        [app setNoteController:nil];
    } else {
        [app setNoteListViewController:[[NoteListViewController alloc] initWithNode:node]];
    }
}

@end
