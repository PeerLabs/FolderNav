//
//  DataDefinition.h
//  FolderNav
//
//  Created by Morten Norby Larsen on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// Plain, old fashioned define statements to 
// set the type identifiers (not seen by the user) 
// and the user-facing names of the folders


#ifndef FolderNav_DataDefinition_h
#define FolderNav_DataDefinition_h

#define FOLDER_ENTITY @"Folder"
#define OBJECT_ENTITY @"Object"

#define FOLDER_TITLE @"title"
#define FOLDER_TYPE  @"type"

#define OBJECT_TITLE @"title"
#define OBJECT_TEXT  @"text"

#define FOLDER_TYPE_CURRENT_UNFILED @"CurrentUnfiled"
#define FOLDER_TYPE_TRASH           @"Trash"
#define FOLDER_TYPE_DRAFTS          @"Drafts"
#define FOLDER_TYPE_USER_DEFINED    @"UserDefined"


// User-facing strings (names of permanent folders)
#define FOLDER_TITLE_EN_CURRENT_UNFILED @"Current Unfiled"
#define FOLDER_TITLE_EN_TRASH           @"Trash"
#define FOLDER_TITLE_EN_DRAFTS          @"Drafts"


// Core Data strings

#define FOLDER_FETCH_CACHE_NAME @"Folders"


#endif