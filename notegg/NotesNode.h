//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import <Foundation/Foundation.h>

@class BaseOutlineViewController;
@class NoteController;

@interface NotesNode : NSObject

+ (NotesNode *)rootNode:(NotesNode *)node WithDelegate:(BaseOutlineViewController *)outlineViewController;

// Properties needed by NSOutlineView to draw the outline item
@property (nonatomic, assign) BOOL isExpandable;
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *childNodes;

// Operations
- (void)addChild;
- (void)remove;
- (void)moveToIndex:(NSInteger)index inParent:(NotesNode *)parent;
- (BOOL)canMoveToIndex:(NSInteger)index inParent:(NotesNode *)parent;

// Controller used to show detail view
- (NoteController *)contentController;

@end
