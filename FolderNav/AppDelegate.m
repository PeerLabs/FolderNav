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
#import "Folder.h"
#import "FolderContentsViewController.h"
#import "ImageBarButtonItem.h"


#define ALERT_VIEW_TAG_UNRECOVERABLE_ERROR 1

void PanicExit(NSError * err) {
    AppDelegate * appDel = [[UIApplication sharedApplication] delegate];
    
    [appDel exitWithError:err];
}

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
    
    UISplitViewController  *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        
    splitViewController.delegate = (id)navigationController.topViewController;

    UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
    MasterViewController   *controller = (MasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext    = self.managedObjectContext;
    
    // Get detail view's navigation item
    
    // Be paranoid
    FolderContentsViewController *detailViewController = nil;

    if ( [navigationController.topViewController isKindOfClass:[FolderContentsViewController class]] ) {
        detailViewController = (FolderContentsViewController *)navigationController.topViewController;
        detailViewController.managedObjectContext = self.managedObjectContext;
    }
    
    UINavigationItem *navItem = [detailViewController navigationItem];


    // Set title
    
    // There is no title in this app.
    navItem.title = nil;

    
    // Set right hand buttons and search field on nav bar
    
    //
    // ## Activate Search bar here ##
    //
    // Commenting out search bar until final designs have been decided.
    //
    // UIBarButtonItem *searchBarItem = [self makeSearchFieldBarButtonItemWithDelegate: detailViewController];
    // detailViewController.searchBar = searchBarItem;
    
    UIBarButtonItem *addObjectBarButtonItem = [[ImageBarButtonItem alloc] initWithImageName:@"addButtonImage" target:detailViewController action:@selector(addObject:)];

    UIBarButtonItem *archiveObjectBarButtonItem = [[ImageBarButtonItem alloc] initWithImageName:@"archiveButtonImage"target:detailViewController action:@selector(renameObject:)];
    
    UIBarButtonItem *deleteObjectBarButtonItem = [[ImageBarButtonItem alloc] initWithImageName:@"deleteButtonImage" target:detailViewController action:@selector(deleteObject:)];
    
    
    navItem.rightBarButtonItems = [NSArray arrayWithObjects: 
                                   deleteObjectBarButtonItem,
                                   archiveObjectBarButtonItem,
                                   addObjectBarButtonItem, 
                                   // Commenting out search bar
                                   // ## Activate it here ##
                                   //searchBarItem, 
                                   nil];

    ExitFunction();    

    return YES;
}



- (UIBarButtonItem *)makeSearchFieldBarButtonItemWithDelegate: (id)aDelegate
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 175, 44)];
    
    searchBar.delegate = aDelegate;
    
    return [[UIBarButtonItem alloc] initWithCustomView:searchBar]; 
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
            PanicExit(error);
        } 
    }
    
    ExitFunction();    
}


#pragma mark -
#pragma mark Graceful(-ish) exit handling

// This method replaces the boiler plate abort() function calls.
// It alerts the user that there was a problem, and exits.
//
// Mostly used for Core Data related problems.
//
- (void)exitWithError: (NSError *)error {
    EnterFunction();

    NSString *errorMessage = error.localizedDescription;
    
    NSString *msgTitle = NSLocalizedString(@"Unrecoverable Error", @"Unrecoverable Error");
    
    NSString *exitButtonTitle = NSLocalizedString(@"Exit", @"Exit button title");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: msgTitle
                                                    message: errorMessage
                                                   delegate: self 
                                          cancelButtonTitle: exitButtonTitle
                                          otherButtonTitles: nil];
    
    alert.tag = ALERT_VIEW_TAG_UNRECOVERABLE_ERROR;
    
    [alert show];
    
    ExitFunction();    
}


- (void)alertView: (UIAlertView *)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{ 
    EnterFunction();
    
    if ( alertView.tag == ALERT_VIEW_TAG_UNRECOVERABLE_ERROR ) {
        [self closeDown];
    }
       
    ExitFunction();    
}


- (void)closeDown
{
    EnterFunction();
    
    exit(0);

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
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        __managedObjectContext = moc;
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
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Migrate datamodel, normal options for Core Data (lightweight migration)
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                    [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                    nil];
    
    // containerID needs to match the entitlements and provisioning profile,
    // or it can be nil. In that case it will use the first key 
    NSString *containerID = nil;
    
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier: containerID];
    
    if ( cloudURL ) {
        // iCloud is available
        
        NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
        
        cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
        
        NSDictionary *iCloudOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"FolderNav.store", NSPersistentStoreUbiquitousContentNameKey,
                                       cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                                       nil];
        
        // Add the iCloud-specific options to the standard ones
        [options addEntriesFromDictionary:iCloudOptions];
    }
    
    NSError *error = nil;
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        PanicExit(error);
    }
    
    DLog(@"Persistent store added");
    
    // Notify controllers (notably, the master view controller)
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PERSISTENT_STORE_CHANGED object:self userInfo:nil];
    
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
    Folder *folder = nil;
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
        
        folder.type = FOLDER_TYPE_CURRENT_UNFILED;
        folder.title = title;
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
        
        folder.type = FOLDER_TYPE_TRASH;
        folder.title = title;
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
        
        folder.type = FOLDER_TYPE_DRAFTS;
        folder.title = title;

    }
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Error saving initial folder database: %@", [error localizedDescription]);
    }      
        
    ExitFunction();    
}


- (void)mergeiCloudChanges:(NSNotification*)notification forContext:(NSManagedObjectContext*)moc {
    [moc mergeChangesFromContextDidSaveNotification:notification]; 
    
    NSNotification* refreshNotification = [NSNotification notificationWithName: NOTIFICATION_DATABASE_MERGED object:self userInfo:[notification userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock: ^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}


@end
