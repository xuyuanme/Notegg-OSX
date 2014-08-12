//
//  NoteListViewController.m
//  notegg
//
//  Created by Yuan on 14-8-7.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "NoteListViewController.h"
#import "AppDelegate.h"

@interface NoteListViewController ()

@end

@implementation NoteListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(NO, @"Call -initWithNode: instead");
    return nil;
}

- (id)initWithNode:(NotesNode *)rootNode {
    self = [super initWithNibName:@"NoteListViewController" bundle:nil];
    if (self) {
        [self setRoot:[NotesNode rootNode:rootNode WithDelegate:self]];
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
    if (![[DBAccountManager sharedManager] linkedAccount]) {
        [app setNotebookListViewController:nil];
        [app setNoteListViewController:nil];
        [app setNoteController:nil];
        [[app accountButton] setHidden:false];
    } else {
        NotesNode *node = [self nodeFromItem:[[self outlineView] itemAtRow:[[self outlineView] selectedRow]]];
        
        // Use NoteController dealloc instead of calling close
        // [[self contentController] close];
        
        [app setNoteController:[node contentController]];
    }
}

@end
