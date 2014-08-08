//
//  NoteListViewController.m
//  notegg
//
//  Created by Yuan on 14-8-7.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "NoteListViewController.h"

@interface NoteListViewController ()

@end

static NotesNode *rootNode;

@implementation NoteListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self outlineView] registerForDraggedTypes:@[@"me.xuyuan.notegg.notes.node"]];
        [self setRoot:[NotesNode rootNode:rootNode WithDelegate:self]];
        [[self outlineView] reloadData];
    }
    return self;
}

+ (void)setRootNode:(NotesNode *)node {
    rootNode = node;
}

@end
