//
//  Folder.h
//  FolderNav
//
//  Created by Morten Norby Larsen on 10/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FolderContent;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *contents;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addContentsObject:(FolderContent *)value;
- (void)removeContentsObject:(FolderContent *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
