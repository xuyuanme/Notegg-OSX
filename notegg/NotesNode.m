//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import "NotesNode.h"
#import "BaseOutlineViewController.h"
#import "NoteController.h"

@interface NotesNode()

@property (nonatomic, weak) BaseOutlineViewController *outlineViewController;
@property (nonatomic, weak) NotesNode *parent;
@property (nonatomic, retain) id data;

- (id)initWithData:(id)data parent:(NotesNode *)parent outlineViewController:(BaseOutlineViewController *)outlineViewController;
- (void)reloadChildNodes;

// methods that concrete subclasses will override for -reloadChildNodes to work
- (NSArray *)fetchChildData;
- (id)keyForChildData:(id)data;
- (Class)childNodeClass;

@end

#pragma mark Concrete subclasses

@interface NotesAccountManagerNode : NotesNode
@property (nonatomic, retain) DBAccountManager *data;
@end

@interface NotesAccountNode : NotesNode
@property (nonatomic, retain) DBAccount *data;
@property (nonatomic, retain) DBFilesystem *filesystem;
@end

@interface NotesFileNode : NotesNode
@property (nonatomic, retain) DBFileInfo *data;
@property (nonatomic, retain) DBFilesystem *filesystem;
@end

@implementation NotesNode

+ (NotesNode *)rootNode:(NotesNode *)rootNode WithDelegate:(BaseOutlineViewController *)outlineViewController {
    if (!rootNode) {
        return [[NotesAccountManagerNode alloc] initWithData:[DBAccountManager sharedManager] parent:nil outlineViewController:outlineViewController];
    } else {
        return [[[rootNode class] alloc] initWithData:[rootNode data] parent:nil outlineViewController:outlineViewController];
    }
}

- (id)init {
    NSAssert(NO, @"Don't call -init directly");
    return nil;
}

- (id)initWithData:(id)data parent:(NotesNode *)parent outlineViewController:(BaseOutlineViewController *)outlineViewController {
    if ((self = [super init])) {
        [self setData:data];
        [self setParent:parent];
        [self setOutlineViewController:outlineViewController];
        [self setIsExpandable:YES];
    }
    return self;
}

- (NSMutableArray*)childNodes {
    if (!_childNodes) {
        NSLog(@"Node %@: load childNodes", [self name]);
        [self setChildNodes:[[NSMutableArray alloc] init]];
        [self reloadChildNodes];
    }
    return _childNodes;
}

- (void)addChild {
}

- (void)remove {
}

- (void)moveToIndex:(NSInteger)index inParent:(NotesNode *)parent {
}

- (BOOL)canMoveToIndex:(NSInteger)index inParent:(NotesNode *)parent {
    return NO;
}

- (Class)childNodeClass {
    return nil;
}

- (id)keyForChildData:(id)data {
    return data;
}

- (NSArray *)fetchChildData {
    return @[];
}

- (void)reloadChildNodes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Fetch the current child data
        NSArray *childData = [self fetchChildData];
        if (childData == nil) {
            return; // assume the only way fetch can return nil is if it errors
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            // Create a dictionary from their identifier to the data.
            NSMutableDictionary *dataById = [[NSMutableDictionary alloc] init];
            for (id data in childData) {
                dataById[[self keyForChildData:data]] = data;
            }

            // newChildNodes will be what we replace childNodes with
            NSMutableArray *newChildNodes = [[NSMutableArray alloc] init];

            // Figure out what we need to remove in the current childNodes
            NSMutableIndexSet *removeIndices = [[NSMutableIndexSet alloc] init];
            for (NSUInteger i = 0; i < _childNodes.count; i++) {
                NotesNode *node = _childNodes[i];
                id key = [self keyForChildData:[node data]];
                if (dataById[key]) {
                    [newChildNodes addObject:node];
                    [dataById removeObjectForKey:key]; // remove so we don't process it again later
                } else {
                    [removeIndices addIndex:i];
                }
            }

            // The remaining entries in dataById are new so create new nodes for them
            NSMutableIndexSet *insertIndices = [[NSMutableIndexSet alloc] init];
            [dataById enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NotesNode *node = [[[self childNodeClass] alloc] initWithData:obj parent:self outlineViewController:[self outlineViewController]];
                [insertIndices addIndex:[newChildNodes count]];
                [newChildNodes addObject:node];
            }];

            // If there were actual changes, set the new childNodes and apply the changes to the outline view
            if ([removeIndices count] || [insertIndices count]) {
                [self setChildNodes:newChildNodes];
                NSLog(@"Node %@: done reload. %lu removed, %lu added. now has %lu children", [self name], [removeIndices count], [insertIndices count], [[self childNodes] count]);

                id outlineItem = [self parent] == nil ? nil : self; // root is represented by nil in the outline view (rather than NotesAccountManagerNode)
                [[[self outlineViewController] outlineView] removeItemsAtIndexes:removeIndices inParent:outlineItem withAnimation:NSTableViewAnimationEffectFade];
                [[[self outlineViewController] outlineView] insertItemsAtIndexes:insertIndices inParent:outlineItem withAnimation:NSTableViewAnimationEffectFade];
            } else {
                NSLog(@"Node %@: done reload. no changes to children.", [self name]);
            }
        });
    });
}

- (NoteController *)contentController {
    return nil;
}

+ (void)promptForFileNameAndCreateUnderParent:(DBPath *)parentPath inFilesystem:(DBFilesystem *)filesystem {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter name:"
                                     defaultButton:@"Add file"
                                   alternateButton:@"Cancel"
                                       otherButton:@"Add folder"
                         informativeTextWithFormat:@""];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [alert setAccessoryView:input];
    NSInteger ret = [alert runModal];
    if (ret == NSAlertDefaultReturn) {
        if ([[input stringValue] length]) {
            [filesystem createFile:[parentPath childPath:[NSString stringWithFormat:@"%@.txt", [input stringValue]]] error:nil];
        }
    } else if (ret == NSAlertOtherReturn) {
        [filesystem createFolder:[parentPath childPath:[input stringValue]] error:nil];
    }
}

@end


@implementation NotesAccountManagerNode

- (id)initWithData:(DBAccountManager*)data parent:(NotesNode *)parent outlineViewController:(BaseOutlineViewController *)app {
    if ((self = [super initWithData:data parent:parent outlineViewController:app])) {
        __weak NotesAccountManagerNode *weakSelf = self;
        [data addObserver:self block:^(DBAccount *account) {
            NSLog(@"Node %@: observed changes, reloading", [weakSelf name]);
            [weakSelf reloadChildNodes];
        }];
        [self setName:@"AccountManager"];
        NSLog(@"Created node: %@", [self name]);
    }
    return self;
}

- (void)dealloc {
    [[self data] removeObserver:self];
    NSLog(@"Dealloced node: %@", [self name]);
}

- (void)addChild {
//    [[self data] linkFromWindow:[[self app] window] withCompletionBlock:nil];
}

- (Class)childNodeClass {
    return [NotesAccountNode class];
}

- (NSString *)keyForChildData:(DBAccount *)data {
    return [data userId];
}

- (NSArray *)fetchChildData {
    NSArray *ret = [[self data] linkedAccounts];
    return ret == nil ? @[] : ret;
}

@end


@implementation NotesAccountNode

- (id)initWithData:(DBAccount *)data parent:(NotesNode *)parent outlineViewController:(BaseOutlineViewController *)app {
    if ((self = [super initWithData:data parent:parent outlineViewController:app])) {
        [self setFilesystem:[DBFilesystem sharedFilesystem]];
        __weak NotesAccountNode *weakSelf = self;
        [[self filesystem] addObserver:self forPathAndChildren:[DBPath root] block:^{
            NSLog(@"Node %@: observed changes, reloading", [weakSelf name]);
            [weakSelf reloadChildNodes];
        }];
        [data addObserver:self block:^{
            NSString *name = [[[weakSelf data] info] displayName];
            if (name && ![[weakSelf name] isEqualToString:name]) {
                [weakSelf setName:name];
            }
        }];
        NSString *name = [[[self data] info] displayName];
        [self setName:(name ? name : @"")];
        [self setIcon:[NSImage imageNamed:NSImageNameUser]];
        NSLog(@"Created node: %@", [self name]);
    }
    return self;
}

- (void)dealloc {
    [[self filesystem] removeObserver:self];
    [[self data] removeObserver:self];
    NSLog(@"Dealloced node: %@", [self name]);
}

- (void)addChild {
    DBPath *parentPath = [DBPath root];
    [NotesNode promptForFileNameAndCreateUnderParent:parentPath inFilesystem:[self filesystem]];
}

- (void)remove {
    [[self data] unlink];
}

- (Class)childNodeClass {
    return [NotesFileNode class];
}

- (NSArray *)keyForChildData:(DBFileInfo *)data {
    // A file node is uniquely identified (for the purposes of this app) by its path and whether it's a folder
    return @[[data path], @([data isFolder])];
}

- (NSArray *)fetchChildData {
    return [[self filesystem] listFolder:[DBPath root] error:nil];
}

@end


@implementation NotesFileNode

- (id)initWithData:(DBFileInfo *)data parent:(NotesNode *)parent outlineViewController:(BaseOutlineViewController *)app {
    if ((self = [super initWithData:data parent:parent outlineViewController:app])) {
        if ([(id)parent filesystem]) {
            [self setFilesystem:[(id)parent filesystem]];
        } else {
            [self setFilesystem:[DBFilesystem sharedFilesystem]];
        }
        
        if ([data isFolder]) {
            __weak NotesFileNode *weakSelf = self;
            [[self filesystem] addObserver:self forPathAndChildren:[data path] block:^{
                NSLog(@"Node %@: observed changes, reloading", [weakSelf name]);
                [weakSelf reloadChildNodes];
            }];
        }
        [super setName:[[[[self data] path] stringValue] lastPathComponent]];
        if ([[self data] isFolder]) {
            [self setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)]];
        } else {
            [self setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:[[[[[self data] path] stringValue] pathExtension] lowercaseString]]];
        }
        // [self setIsExpandable:[[self data] isFolder]];
        [self setIsExpandable:NO];
        NSLog(@"Created node: %@", [self name]);
    }
    return self;
}

- (void)dealloc {
    if ([[self data] isFolder]) {
        [[self filesystem] removeObserver:self];
    }
    NSLog(@"Dealloced node: %@", [self name]);
}

- (void)setName:(NSString *)name {
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError {
    // Didn't want to write validation logic so just do the rename here and see if it fails
    DBError *error = nil;
    [[self filesystem] movePath:[[self data] path]
                         toPath:[[[[self data] path] parent] childPath:*ioValue]
                          error:&error];
    if (error == nil) {
        return YES;
    }
    return NO;
}

- (void)addChild {
    DBFileInfo *fileInfo = [self data];
    if ([fileInfo isFolder]) {
        // is folder so add as child of this folder
        DBPath *parentPath = [fileInfo path];
        [NotesNode promptForFileNameAndCreateUnderParent:parentPath inFilesystem:[self filesystem]];
    } else {
        // is a file so add as a sibling of this file
        [[self parent] addChild];
    }
}

- (void)remove {
    [[self filesystem] deletePath:[[self data] path] error:nil];
}

- (void)moveToIndex:(NSInteger)index inParent:(NotesNode *)parent {
    NSString *name = [[[[self data] path] stringValue] lastPathComponent];

    DBPath *parentPath = nil;
    if ([parent isKindOfClass:[NotesAccountNode class]]) {
        parentPath = [DBPath root];
    } else {
        parentPath = [[(NotesFileNode *)parent data] path];
    }

    DBPath *fromPath = [[self data] path];
    DBPath *toPath = [parentPath childPath:name];
    [[self filesystem] movePath:fromPath toPath:toPath error:nil];
}

- (BOOL)canMoveToIndex:(NSInteger)index inParent:(NotesNode *)parent {
    if (index != NSOutlineViewDropOnItemIndex) {
        // Disallow rearrangements (has to be a move directly into another item)
        return NO;
    }
    if ([self parent] == parent) {
        // Disallow no-ops (move back to same folder)
        return NO;
    }
    if (![parent isExpandable] ) {
        // Make sure it's into an account (representing root folder) or folder
        return NO;
    }

    NSString *parentPath = nil;
    if ([parent isKindOfClass:[NotesAccountNode class]]) {
        parentPath = [[DBPath root] stringValue];
    } else if ([parent isKindOfClass:[NotesFileNode class]]) {
        parentPath = [[[(NotesFileNode *)parent data] path] stringValue];
    } else {
        // Can't move into NotesAccountManagerNode
        return NO;
    }
    if ([parentPath hasPrefix:[[[self data] path] stringValue]]) {
        // Make sure the parent path is not actually a descendent
        return NO;
    }

    if (([parent isKindOfClass:[NotesAccountNode class]] &&
        [self filesystem] == [(NotesAccountNode *)parent filesystem]) ||
        ([parent isKindOfClass:[NotesFileNode class]] &&
         [self filesystem] == [(NotesFileNode *)parent filesystem])) {
        // Make sure it is moved within the same filesystem
        return YES;
    }
    return NO;
}

- (Class)childNodeClass {
    return [NotesFileNode class];
}

- (NSArray *)keyForChildData:(DBFileInfo *)data {
    // A file node is uniquely identified (for the purposes of this app) by its path and whether it's a folder
    return @[[data path], @([data isFolder])];
}

- (NSArray *)fetchChildData {
    if ([[self data] isFolder]) {
        if ([[self filesystem] fileInfoForPath:[[self data] path] error:nil] == nil) {
            return nil;
        }
        return [[self filesystem] listFolder:[[self data] path] error:nil];
    } else {
        return nil;
    }
}

- (NoteController *)contentController {
    if (![[self data] isFolder]) {
        return [[NoteController alloc] initWithFile:[[self filesystem] openFile:[[self data] path] error:nil]];
    }
    return nil;
}

@end
