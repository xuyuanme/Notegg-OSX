//
//  BaseOutlineViewController.h
//  notegg
//
//  Created by Yuan on 14-8-7.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotesNode.h"

@interface BaseOutlineViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, retain) NotesNode *root;
@property (nonatomic, retain) NotesNode *draggedNode;

@end
