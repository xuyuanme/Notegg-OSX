//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import "NoteController.h"

@implementation NoteController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSAssert(NO, @"Call -initWithFile: instead");
    return nil;
}

- (id)initWithFile:(DBFile *)file {
    if ((self = [super initWithNibName:@"NoteController" bundle:nil])) {
        [self setFile:file];
        [self setDoneLoading:NO];
    }
    return self;
}

-(void)awakeFromNib {
    if ([self file]) {
        // Is a file, start loading
        [[self fileNameLabel] setStringValue:@""];
        [[self savedLabel] setHidden:YES];
        [[self scrollView] setHidden:YES];
        [[self textView] setString:@""];
        [[self loadingSpinner] startAnimation:self];
        [[self loadingSpinner] setHidden:NO];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (![[self file] isOpen]) {
                return;
            }
            // Get the file contents
            NSString *content = [[self file] readString:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[self file] isOpen]) {
                    return;
                }
                // Setup observers to reload whenever there's any remote changes
                __unsafe_unretained NoteController *weakSelf = self;
                [[self file] addObserver:self block:^{
                    if (![[weakSelf file] isOpen]) {
                        return;
                    }

                    // Update title. TODO: if the filename actually changed we should reselect the correct node in outline
                    [[weakSelf fileNameLabel] setStringValue:[[[[weakSelf file] info] path] stringValue]];

                    // Update contents to newer version if ready
                    if ([[[weakSelf file] newerStatus] cached]) {
                        NSLog(@"File newer content ready");
                        [weakSelf syncTextView];
                    }
                }];

                // Initial load of file contents
                [[self fileNameLabel] setStringValue:[[[[self file] info] path] stringValue]];
                [self setNeedsSave:NO];
                [[self savedLabel] setHidden:NO];
                [[self loadingSpinner] setHidden:YES];
                if (content) {
                    [[self scrollView] setHidden:NO];
                    [[self textView] setString:content];
                }

                [self setDoneLoading:YES];
            });
        });
    } else {
        // Is a account or folder, show nothing
        [[self loadingSpinner] setHidden:YES];
        [[self scrollView] setHidden:YES];
    }
}


# pragma mark - NSTextDelegate

- (void)textDidChange:(NSNotification *)notification {
    if (![self doneLoading]) {
        return;
    }
    // Save contents 500ms after typing has stopped
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTextView) object:nil];
    [self performSelector:@selector(syncTextView) withObject:nil afterDelay:.5];
    [self setNeedsSave:YES];
    [[self savedLabel] setHidden:YES];
}

# pragma mark - Helpers

- (void)syncTextView {
    if (![self doneLoading]) {
        return;
    }
    if ([self needsSave]) {
        if ([[[self file] newerStatus] cached]) {
            // Need to save local edits but have a cached remote version. Need to choose which to keep.
            NSAlert *alert = [NSAlert alertWithMessageText:@"Warning: Newer version of this file is available."
                                             defaultButton:@"Update to remote version"
                                           alternateButton:@"Save local version"
                                               otherButton:nil
                                 informativeTextWithFormat:@""];
            if ([alert runModal] == NSAlertDefaultReturn) {
                // Take remote copy (and update our textView to match)
                [[self file] update:nil];
                [[self textView] setString:[[self file] readString:nil]];
                NSLog(@"File syncTextView - updated to remote");
            } else {
                // Take local copy
                [[self file] update:nil];
                [[self file] writeString:[[self textView] string] error:nil];
                NSLog(@"File syncTextView - updated to local");
            }
        } else {
            // Need to save local edits and no cached remote version, just save
            // (note if there are remote changes and we didn't know about it, this would cause a conflicted copy)
            [[self file] writeString:[[self textView] string] error:nil];
            NSLog(@"File syncTextView - updated to local");
        }
        [[self textView] breakUndoCoalescing];
        [self setNeedsSave:NO];
        [[self savedLabel] setHidden:NO];
    } else if ([[[self file] newerStatus] cached]) {
        // no local edits and have a cached remote version, update to remote version
        [[self file] update:nil];
        [[self textView] setString:[[self file] readString:nil]];
        NSLog(@"File syncTextView - updated to remote");
    }
}

- (void)close {
    if ([self doneLoading]) {
        [[self file] removeObserver:self];
        if ([self needsSave]) {
            // About to switch away. Cancel the deferred syncTextView and do it now
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTextView) object:nil];
            [self syncTextView];
        }
    }
    [[self file] close];
}

@end
