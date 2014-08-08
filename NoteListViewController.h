//
//  NoteListViewController.h
//  notegg
//
//  Created by Yuan on 14-8-7.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "BaseOutlineViewController.h"

@interface NoteListViewController : BaseOutlineViewController

@property (weak) IBOutlet NSOutlineView *outlineView;

+ (void)setRootNode:(NotesNode *)node;

@end
