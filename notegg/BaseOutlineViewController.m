//
//  BaseOutlineViewController.m
//  notegg
//
//  Created by Yuan on 14-8-7.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "BaseOutlineViewController.h"

@interface BaseOutlineViewController ()

@end

@implementation BaseOutlineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

# pragma mark - NSOutlineViewDataSource - Data source

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [[self nodeFromItem:item] isExpandable];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[[self nodeFromItem:item] childNodes] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [[self nodeFromItem:item] childNodes][index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return [self nodeFromItem:item];
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSLog(@"TODO: Need to implement sort");
}

# pragma mark - NSOutlineViewDataSource - Drag and Drop

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
    [self setDraggedNode:item];
    
    NSPasteboardItem *pasteBoardItem = [[NSPasteboardItem alloc] init];
    [pasteBoardItem setData:[NSData data] forType:@"me.xuyuan.notegg.notes.node"];
    return pasteBoardItem;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if ([self draggedNode] && [[self draggedNode] canMoveToIndex:index inParent:[self nodeFromItem:item]]) {
        // TODO: Implement drag and drop later
        // return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    if ([self draggedNode]) {
        [[self draggedNode] moveToIndex:index inParent:[self nodeFromItem:item]];
        return YES;
    }
    return NO;
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    [self setDraggedNode:nil];
}

# pragma mark - NSOutlineViewDelegate - View

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // view is populated via bindings to item's icon and name
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    //[[cellView textField] setEditable: [[item parent] parent] == nil ? NO : YES];
    [[cellView textField] setEditable: YES];
    return cellView;
}

# pragma mark - Helpers

- (NotesNode *)nodeFromItem:(id)item {
    // NSOutlineView treats nil as the root, so translate that to our real root
    return item ? item : [self root];
}

@end
