//
//  NotebookListViewController.m
//  notegg
//
//  Created by Yuan on 14-8-6.
//  Copyright (c) 2014年 xuyuanme. All rights reserved.
//

#import "NotebookListViewController.h"

@interface NotebookListViewController ()

@end

@implementation NotebookListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)addButtonClicked:(id)sender {
    DBAccount *linkedAccount = [[DBAccountManager sharedManager] linkedAccount];
    if (linkedAccount) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromWindow:self.view.window
                                     withCompletionBlock:^(DBAccount *account) {
                                         if (account) {
                                             NSLog(@"App linked successfully!");
                                         }
                                     }];
    }
}

@end
