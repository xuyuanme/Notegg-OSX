//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <Dropbox/Dropbox.h>
#import "NotesNode.h"

@interface NoteController : NSViewController <NSTextDelegate>

@property (weak) IBOutlet NSTextField *fileNameLabel;
@property (weak) IBOutlet NSTextField *savedLabel;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSProgressIndicator *loadingSpinner;

@property (nonatomic, retain) DBFile *file;
@property (nonatomic, assign) BOOL needsSave;
@property (nonatomic, assign) BOOL doneLoading;

- (id)initWithFile:(DBFile *)file;
- (void)close;

@end
