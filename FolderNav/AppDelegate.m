//
//  AppDelegate.m
//  FolderNav
//
//  Created by Morten Norby Larsen on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DataDefinition.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize permanentFolderTypes = _permanentFolderTypes;
@synthesize allFolderTypes       = _allFolderTypes;

// Populate Core Data with static folders
//
// Initialise folder type arrays
//
// These are the type flags for the currently 3 types of folders
// that are created initially and cannot be deleted.
//
// There is only one of each of these folder types, and
// the array serves for ordering, too.
//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    EnterFunction();
    
    _permanentFolderTypes = [NSArray arrayWithObjects:
                            FOLDER_TYPE_CURRENT_UNFILED,
                            FOLDER_TYPE_TRASH,
                            FOLDER_TYPE_DRAFTS,
                            nil];
    
    _allFolderTypes = [_permanentFolderTypes arrayByAddingObject: FOLDER_TYPE_USER_DEFINED];
    
    [self setupFolders];
    
    
    // Set up controllers
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;

    UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    return YES;
    
    ExitFunction();    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    EnterFunction();
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    ExitFunction();    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    EnterFunction();
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    ExitFunction();    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    EnterFunction();
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    ExitFunction();    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    EnterFunction();
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    ExitFunction();    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    EnterFunction();
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    ExitFunction();    
}

- (void)saveContext
{
    EnterFunction();
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    
    ExitFunction();    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    EnterFunction();
    
    if (__managedObjectContext != nil) {

        ExitFunction();
        
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    ExitFunction();    

    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    EnterFunction();
    
    if (__managedObjectModel != nil) {
        
        ExitFunction();    

        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FolderNav" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    ExitFunction();    

    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    EnterFunction();
    
    if (__persistentStoreCoordinator != nil) {
    
        ExitFunction();    

        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FolderNav.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    ExitFunction();    

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    EnterFunction();
        
    ExitFunction();    

    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Set up folders in Core Data

// Check for the presence of the permanent folders, and if not present,
// create them.
//
// The primary purpose of this method is to initialise the Core Data
// data base on first launch - secondary to provide robustness in 
// case one of the primary folders has been deleted.
//
- (void)setupFolders
{
    EnterFunction();
    
    // This query is just to check if the folder database is initialised and populated correctly
    
    // Fetch all folders (they are not that many,) 
    // then check if the three mandatory ones are defined
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName: FOLDER_ENTITY 
                                   inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *folders = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    
    // Prepare to check for specific folders
    
    // Predicate format string to check folder type
    NSString *format = @"self.type = %@";
    NSPredicate *p = nil;
    NSArray *filteredFolders = nil;
    NSManagedObject *folder = nil;
    NSString *title = nil;

    
    // Check for the Current Unfiled folder
    
    p = [NSPredicate predicateWithFormat: format, FOLDER_TYPE_CURRENT_UNFILED];

    filteredFolders = [folders filteredArrayUsingPredicate:p];
    
    if ( filteredFolders.count == 0 ) {
        // Add the Current Unfiled folder
        
        folder = [NSEntityDescription
                               insertNewObjectForEntityForName: FOLDER_ENTITY 
                               inManagedObjectContext:self.managedObjectContext];            
        
        title = NSLocalizedString(FOLDER_TITLE_EN_CURRENT_UNFILED, FOLDER_TITLE_EN_CURRENT_UNFILED);
        
        [folder setValue: FOLDER_TYPE_CURRENT_UNFILED forKey: FOLDER_TYPE];
        [folder setValue: title forKey: FOLDER_TITLE];
    }
    

    // Check for the Trash folder
    
    p = [NSPredicate predicateWithFormat: format, FOLDER_TYPE_TRASH];
    
    filteredFolders = [folders filteredArrayUsingPredicate:p];
    
    if ( filteredFolders.count == 0 ) {
        // Add the Trash folder
        
        folder = [NSEntityDescription
                  insertNewObjectForEntityForName: FOLDER_ENTITY 
                  inManagedObjectContext:self.managedObjectContext];            
        
        title = NSLocalizedString(FOLDER_TITLE_EN_TRASH, FOLDER_TITLE_EN_TRASH);
        
        [folder setValue:FOLDER_TYPE_TRASH forKey: FOLDER_TYPE];
        [folder setValue:title forKey: FOLDER_TITLE];        
    }
    
    
    // Check for the Drafts folder
    
    p = [NSPredicate predicateWithFormat: format, FOLDER_TYPE_DRAFTS];
    
    filteredFolders = [folders filteredArrayUsingPredicate:p];
    
    if ( filteredFolders.count == 0 ) {
        // Add the Drafts folder
        
        folder = [NSEntityDescription
                  insertNewObjectForEntityForName: FOLDER_ENTITY 
                  inManagedObjectContext:self.managedObjectContext];            
        
        title = NSLocalizedString(FOLDER_TITLE_EN_DRAFTS, FOLDER_TITLE_EN_DRAFTS);
        
        [folder setValue:FOLDER_TYPE_DRAFTS forKey: FOLDER_TYPE];
        [folder setValue:title forKey: FOLDER_TITLE];        
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error saving initial folder database: %@", [error localizedDescription]);
    }      
        
    ExitFunction();    
}



@end
