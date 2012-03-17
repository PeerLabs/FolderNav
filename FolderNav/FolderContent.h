//
//  FolderContent.h
//  FolderNav
//
//  Created by Morten Norby Larsen on 10/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder;

@interface FolderContent : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Folder *folder;

@end
