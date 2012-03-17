//
//  MasterViewController.m
//  FolderNav
//
//  Created by Morten Norby Larsen on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DataDefinition.h"

#import "DetailViewController.h"
#import "AppDelegate.h"


// Tags to distinguish alert views in delegate methods
#define ALERT_VIEW_TAG_NEW_FOLDER 500
#define ALERT_VIEW_TAG_RENAME_FOLDER 501
#define ALERT_VIEW_TAG_DELETE_FOLDER 502



@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController {
    NSDictionary *deleteAlertUserInfo;
}

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize searchBar = _searchBar;

- (void)awakeFromNib
{
    EnterFunction();
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    [super awakeFromNib];
    
    ExitFunction();
}

// Configure the master view with a search bar
- (void)viewDidLoad
{
    EnterFunction();

    [super viewDidLoad];

    
    // Set up navigation button
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFolder:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    // Set title 
    
    self.title = NSLocalizedString(@"Folders", @"Folder view title");
        
    
    // Added to FolderNav:
    // Set up search bar
    
    UISearchBar *sb = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    sb.autocorrectionType=UITextAutocorrectionTypeNo;
    sb.autocapitalizationType=UITextAutocapitalizationTypeNone;
    sb.delegate=self;
    
    self.searchBar = sb;
    
    self.tableView.tableHeaderView=self.searchBar;
    
    ExitFunction();    
}

- (void)viewDidUnload
{
    EnterFunction();
    
    [super viewDidUnload];
    
    ExitFunction();    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    EnterFunction();
    
    ExitFunction();    

    return YES;
}


#pragma mark -
#pragma mark Manipulating folders

- (void)addFolder:(id)sender
{
    EnterFunction();
    
    // Open a new folder for the user to enter the name
    
    NSString *newFolderDialogTitle   = NSLocalizedString(@"New Folder Name", @"New Folder Dialog Title");
    NSString *newFolderDialogMessage = NSLocalizedString(@""               , @"New Folder Dialog Message");
    
    NSString *newFolderDialogCancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel");
    NSString *newFolderDialogOKButtonTitle     = NSLocalizedString(@"OK"    , @"New Folder Dialog OK");
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:newFolderDialogTitle 
                                                     message:newFolderDialogMessage 
                                                    delegate:self 
                                           cancelButtonTitle:newFolderDialogCancelButtonTitle 
                                           otherButtonTitles:newFolderDialogOKButtonTitle, nil];
    
    // This is so we can distinguish between different alerts in the delegate methods.
    alert.tag = ALERT_VIEW_TAG_NEW_FOLDER;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alert show];  
    
    ExitFunction();    
}


-(void)createNewFolderWithName: (NSString *)name
{
    EnterFunction();
    
    NSAssert(name.length > 0, @"New folder name must not be an empty string");
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue: name forKey: FOLDER_TITLE];
    [newManagedObject setValue: FOLDER_TYPE_USER_DEFINED forKey: FOLDER_TYPE];
    
    // Save the context.
    NSError *error = nil;
    if (![context save: &error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    ExitFunction();    
}


#pragma mark -
#pragma mark Alert view delegate methods

// This master view controller also works as a delegate for the 
// various alert views used during handling of the folders.
//
// To distinguish between alert views (new folder, delete folder,)
// tags are used.

// This method is called when the user clicks a button on an alert
// view. If it was the OK button, we just call the actual mehtods
// that do the real work.
- (void)alertView: (UIAlertView *)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{ 
    EnterFunction();
        
    if ( alertView.tag == ALERT_VIEW_TAG_NEW_FOLDER ) {
        NSString *nameEntered = [[alertView textFieldAtIndex:0] text];
        
        NSLog(@"Folder Name Alert View, Button clicked: %d, Name Entered: %@", buttonIndex, nameEntered);
        
        if ( buttonIndex == 1 ) {
            [self createNewFolderWithName: nameEntered];
        }
    }
    else if ( alertView.tag == ALERT_VIEW_TAG_RENAME_FOLDER ) {
        NSLog(@"Folder renamed");
    }
    else if ( alertView.tag == ALERT_VIEW_TAG_DELETE_FOLDER ) {
        
        if ( buttonIndex == 1 ) {
            NSLog(@"User really, really wants to delete folder");
            
            // Get the index path of the folder to delete out of the 
            // deleteAlertUserInfo ivar, then set it to nil to 
            // return to its neutral state.
            NSIndexPath *indexPath = [deleteAlertUserInfo valueForKey: @"indexPath"];
            
            deleteAlertUserInfo = nil;
            
            [self permanentlyDeleteFolderAtIndexPath: indexPath];
        }
    }
    
    ExitFunction();    
}


- (BOOL)alertViewShouldEnableFirstOtherButton: (UIAlertView *)alertView
{
    EnterFunction();
    
    BOOL answer;
    if ( alertView.tag == ALERT_VIEW_TAG_NEW_FOLDER ) {
        answer = [[[alertView textFieldAtIndex:0] text] length] > 0;
    }
    else {
        answer = YES;
    }
    
    ExitFunction();

    return answer;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    EnterFunction();
    
    ExitFunction();

    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EnterFunction();
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    ExitFunction();

    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    ExitFunction();

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    ExitFunction();
    
    return indexPath.row >= appDel.permanentFolderTypes.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    // FolderNav requires an extra user confirmation with an alert view before 
    // actually deleting the folder, so we call -showDeleteConfirmationAlert to
    // do that.
    //
    // In order to have clean access to information about the folder to 
    // delete, we store it in a "userInfo" structure implemented as an
    // old fashioned ivar.
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        deleteAlertUserInfo = [NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
        
        [self showDeleteConfirmationAlert];
    }   
    
    ExitFunction();
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    // The table view should not be re-orderable.
    
    ExitFunction();

    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = object;
    
    ExitFunction();
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    EnterFunction();
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    
    // Make a fetch request that fetches all folders, in the correct order
    NSFetchRequest *fetchRequest = [self makeFetchRequest: nil];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName: nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    ExitFunction();
   
    return __fetchedResultsController;
}    


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    EnterFunction();
    
    [self.tableView beginUpdates];
    
    ExitFunction();
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    EnterFunction();
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    ExitFunction();
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    EnterFunction();
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    ExitFunction();
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    EnterFunction();
    
    [self.tableView endUpdates];
    
    ExitFunction();
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:FOLDER_TITLE];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    ExitFunction();
}


// This method defines the fetch request that will retrieve the folders
// from Core Data, ordered as required for the user.
//
// The ordering means that the permanent folders are displayed first, 
// then the user defined ones.
//
// The ordering of the permanent folders is determined by the order of
// corresponding type tags in the "permanentFolderTypes" property
// of the AppDelegate class.
// 
// The user-defined folders are sorted alphabetically (in fact, all
// folder types are sorted alphabetically within their types, but for
// the permanent folders, there is only one folder for each type.
- (NSFetchRequest *) makeFetchRequest: (NSPredicate *)p
{
    EnterFunction();
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: FOLDER_ENTITY inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;
    
    if ( p ) {
        fetchRequest.predicate = p;
    }
    
    //
    // Ordering of the folders.
    // First, sort by type (the three special folders), then the rest alphabetically.
    //
    // typeSortDescriptor sorts the special first, then the user folders.
    //
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:FOLDER_TYPE ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSUInteger index1 = [appDel.allFolderTypes indexOfObject:obj1];
        NSUInteger index2 = [appDel.allFolderTypes indexOfObject:obj2];
        
        NSAssert1(index1 != NSNotFound, @"Folder type not defined: %@", obj1);
        NSAssert1(index2 != NSNotFound, @"Folder type not defined: %@", obj2);
        
        return [[NSNumber numberWithUnsignedInteger:index1] compare:[NSNumber numberWithUnsignedInteger:index2]];
    }];
    
    // Now, sort the user defined folders.
    // Folders should be ordered by something else but the title, change this sort descriptor
    
    NSSortDescriptor *userFolderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:FOLDER_TITLE ascending:YES];
    
    
    // Set the two sort descriptors on the fetch request, in the right order
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:
                                    typeSortDescriptor, 
                                    userFolderSortDescriptor, 
                                    nil];
    
    ExitFunction();

    return fetchRequest;
}



#pragma mark -
#pragma mark Folder handling methods

-(void)showDeleteConfirmationAlert
{
    EnterFunction();
    
    NSString *title   = NSLocalizedString(@"Delete Folder", @"Delete Folder Dialog Title");
    NSString *message = NSLocalizedString(@""             , @"Delete Folder Dialog Message");
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel");
    NSString *deleteButtonTitle = NSLocalizedString(@"Delete", @"Delete Folder Delete Button");
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title 
                                                     message:message 
                                                    delegate:self 
                                           cancelButtonTitle:cancelButtonTitle 
                                           otherButtonTitles:deleteButtonTitle, nil];
    
    // This is so we can distinguish between different alerts in the delegate methods.
    alert.tag = ALERT_VIEW_TAG_DELETE_FOLDER;
    
    [alert show];
    
    ExitFunction();
}


- (void)permanentlyDeleteFolderAtIndexPath: (NSIndexPath *)indexPath
{
    EnterFunction();
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Set detail view value to nil.
    self.detailViewController.detailItem = nil;

    ExitFunction();
}





#pragma mark -
#pragma mark Search bar delegate methods

// When the text changes in the search, create a predicate for the
// query into the Core Data storage.
//
// An alternative implementation could be to just filter the 
// folders in-memory. Easier, but slightly less Core Data-like.
//
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    EnterFunction();
    
    NSLog(@"Search text: %@", searchText);
    
    // Set a predicate corresponding to the search
    
    NSPredicate *p = nil;
    if (self.searchBar.text && self.searchBar.text.length > 0)
    {
        p =[NSPredicate predicateWithFormat:@"%K contains[cd] %@", FOLDER_TITLE, self.searchBar.text];
    }    
    
    [self.fetchedResultsController.fetchRequest setPredicate: p];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();  // Fail
    } 
    
    // reload the table view
    [self.tableView reloadData];
    
    ExitFunction();
}


// When the user taps Cancel, drop the search and make the 
// keyboard go away by resigning first responder.
//
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    EnterFunction();
    
    self.searchBar.text = nil;
    
    [self.searchBar resignFirstResponder];
    
    ExitFunction();
}


// Make the Cancel button appear when the user activates the
// search bar
//
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    EnterFunction();
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    ExitFunction();
}

// Make it disappear as soon as the focus is lost.
//
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    EnterFunction();
    
    [self.searchBar setShowsCancelButton:NO animated:YES];

    ExitFunction();
}

@end
