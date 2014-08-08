//
//  NotebookListViewController.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "NotebookListViewController.h"
#import "NoteListViewController.h"
#import "AppDelegate.h"

@interface NotebookListViewController ()

@property (nonatomic,strong) IBOutlet NoteListViewController *noteListViewController;

@end

@implementation NotebookListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self outlineView] registerForDraggedTypes:@[@"me.xuyuan.notegg.notes.node"]];
        [self setRoot:[NotesNode rootNode:nil WithDelegate:self]];
        [[self outlineView] reloadData];
    }
    return self;
}

# pragma mark - NSOutlineViewDelegate - Selection

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    AppDelegate *app = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NotesNode *node = [self nodeFromItem:[[self outlineView] itemAtRow:[[self outlineView] selectedRow]]];
    // TODO: NoteListViewController initWithNibName is called twice, need fix
    [NoteListViewController setRootNode:node];
    _noteListViewController = [[NoteListViewController alloc] initWithNibName:@"NoteListViewController" bundle:nil];
    [[_noteListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[_noteListViewController view] setFrame:[[app noteListView] bounds]];
    
    [[app noteListView] addSubview:[_noteListViewController view]];
}

@end
