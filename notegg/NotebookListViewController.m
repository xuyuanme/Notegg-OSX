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
        [[app noteListView] setSubviews:@[]];
        [[app noteContentView] setSubviews:@[]];
    } else {
        _noteListViewController = [[NoteListViewController alloc] initWithNode:node];
        [[_noteListViewController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        [[_noteListViewController view] setFrame:[[app noteListView] bounds]];
        
        [[app noteListView] setSubviews:@[[_noteListViewController view]]];
    }
}

@end
