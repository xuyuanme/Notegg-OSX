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

@implementation NoteListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self outlineView] registerForDraggedTypes:@[@"com.dropbox.example.notes.node"]];
        [self setRoot:[NotesNode rootNodeWithDelegate:self]];
        [[self outlineView] reloadData];
    }
    return self;
}

@end
