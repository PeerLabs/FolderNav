//
//  DetailViewController.h
//  FolderNav
//
//  Created by Morten Norby Larsen on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Folder;

@interface FolderContentsViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Folder *folder;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void)updateContents;

@end
