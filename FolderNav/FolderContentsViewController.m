//
//  DetailViewController.m
//  FolderNav
//
//  Created by Morten Norby Larsen on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FolderContentsViewController.h"

#import "DataDefinition.h"
#import "Folder.h"
#import "FolderContent.h"
#import "AppDelegate.h"

#define ALERT_VIEW_TAG_RENAME_FOLDER_CONTENT 1

@interface FolderContentsViewController () 

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *contentsOrdered;

- (void)configureView;
@end

@implementation FolderContentsViewController {
    // "Private" ivars
    NSDictionary    *alertUserInfo;
    UIBarButtonItem *folderBarButtonItem;
    NSIndexPath     *currentSelectedIndexPath;
}

@synthesize managedObjectContext  = _managedObjectContext;

@synthesize folder = _folder;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize contentsOrdered = _contentsOrdered;

#pragma mark - Managing the detail item

- (void)setFolder:(id)newFolder
{
    EnterFunction();
    
    if (_folder != newFolder) {
        _folder = newFolder;
     
        currentSelectedIndexPath = nil;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
    
    // Update the view.
    [self configureView];
    
    [self configureNavBar];

    ExitFunction();
}


// Update contents, for instance if iCloud has updated 
// the database
- (void)updateContents
{
    EnterFunction();

    // We can actually just call configureView
    [self configureView];
    
    ExitFunction();
}


// Return an array with a single sort descriptor to 
// sort contents alphabetically by title
- (NSArray *)alphabeticalSortDescriptors
{
    EnterFunction();

    static NSArray *sortDescriptors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:OBJECT_TITLE ascending:YES];
        sortDescriptors = [NSArray arrayWithObject:sd];
    });
    
    ExitFunction();

    return sortDescriptors;
}


- (void)viewDidLoad
{
    EnterFunction();

    [super viewDidLoad];
    
    self.tableView.rowHeight = 100.0f;

    [self configureView];

    ExitFunction();
}

- (void)viewDidUnload
{
    EnterFunction();

    [super viewDidUnload];
    // Release any retained subviews of the main view.

    ExitFunction();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    EnterFunction();

    ExitFunction();

    return YES;
}


#pragma mark -
#pragma mark Configure view and UI

- (void)configureView
{
    EnterFunction();
    // Update the user interface for the detail item.
    
    if (self.folder) {
        
        self.contentsOrdered = [[_folder contents] sortedArrayUsingDescriptors: [self alphabeticalSortDescriptors]];
    }
    else {
        self.contentsOrdered = [NSArray array];
    }
    
    [self.tableView reloadData];
    
    ExitFunction();
}


- (void)configureNavBar
{
    EnterFunction();

    NSString *folderTitle = self.folder.title;

    if ( !folderTitle ) {
        folderTitle = NSLocalizedString(@"Folders", @"Default text on folder button in portrait view");
    }

    folderBarButtonItem.title = folderTitle;
    
    UINavigationItem *navItem = self.navigationItem;
    
    NSArray *buttonItems = navItem.rightBarButtonItems;
    
    UIBarButtonItem *deleteButtonItem = [buttonItems objectAtIndex:0];
    UIBarButtonItem *midButtonItem = [buttonItems objectAtIndex:1];
    UIBarButtonItem *addButtonItem = [buttonItems objectAtIndex:2];

    // Verify that we got the right buttons
    /*
    NSAssert(deleteButtonItem.action == @selector(deleteObject:), @"The buttons items in the upper right hand corner have been moved around. Update configureNavBar");
    NSAssert(midButtonItem.action == @selector(renameObject:), @"The buttons items in the upper right hand corner have been moved around. Update configureNavBar");
    NSAssert(addButtonItem.action == @selector(addObject:), @"The buttons items in the upper right hand corner have been moved around. Update configureNavBar");
    */
    
    // Handle add button
    addButtonItem.enabled = self.folder != nil;
    midButtonItem.enabled = (self.folder != nil) && (self.tableView.indexPathForSelectedRow != nil);
    deleteButtonItem.enabled = (self.folder != nil) && (self.tableView.indexPathForSelectedRow != nil);
    
    ExitFunction();
}



#pragma mark - Handle objects

- (void)addObject: (id)sender
{
    EnterFunction();
    
    NSString *name = [NSString stringWithFormat: @"A string %@", [NSDate date]];
    
    FolderContent *newFolderContent = [NSEntityDescription
                                   insertNewObjectForEntityForName: FOLDERCONTENT_ENTITY
                                   inManagedObjectContext: self.managedObjectContext];
    
    
    
    newFolderContent.title = name;
    newFolderContent.title = @"Some text";
    
    Folder *folder = (Folder *)self.folder;
    
    [folder addContentsObject:newFolderContent];
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save: &error]) {
        PanicExit(error);
    }
    
    // Re-configure view to reflect change
    [self configureView];
    
    ExitFunction();    
}

- (void)renameObject: (id)sender
{
    EnterFunction();
        
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    if ( ! indexPath ) {
        ExitFunction();
        
        return;
    }
        
    // In order to have clean access to information about the folder to 
    // delete, we store it in a "userInfo" structure implemented as an
    // old fashioned ivar.     
    alertUserInfo = [NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
    
    // Open a new folder for the user to enter the name
    
    NSString *renameFolderDialogTitle   = NSLocalizedString(@"New Name", @"Rename Folder Content Dialog Title");
    NSString *renameFolderDialogMessage = NSLocalizedString(@""               , @"Rename Folder Content Dialog Message");
    
    NSString *renameFolderDialogCancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel");
    NSString *renameFolderDialogOKButtonTitle     = NSLocalizedString(@"Rename", @"Rename Folder Content Dialog OK");
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:renameFolderDialogTitle 
                                                     message:renameFolderDialogMessage 
                                                    delegate:self 
                                           cancelButtonTitle:renameFolderDialogCancelButtonTitle 
                                           otherButtonTitles:renameFolderDialogOKButtonTitle, nil];
    
    // This is so we can distinguish between different alerts in the delegate methods.
    alert.tag = ALERT_VIEW_TAG_RENAME_FOLDER_CONTENT;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];  
    

    ExitFunction();
}


- (void)renameFolderContentAtIndex:(NSUInteger)row toName: (NSString *)newName
{
    EnterFunction();

    FolderContent *fc = [self.contentsOrdered objectAtIndex:row];
    
    fc.title = newName;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        PanicExit(error);
    }
    
    ExitFunction();
}


- (void)deleteObject: (id)sender
{
    EnterFunction();

    if ( ! self.tableView.indexPathForSelectedRow ) {
        ExitFunction();
        
        return;
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSUInteger selectedRow = self.tableView.indexPathForSelectedRow.row;
    
    FolderContent *objectToDelete = [self.contentsOrdered objectAtIndex:selectedRow];
    
    [self.folder removeContentsObject: objectToDelete];
        
    NSError *error = nil;
    if (![context save:&error]) {
        PanicExit(error);
    }
    
    currentSelectedIndexPath = nil;
    
    [self configureView];
    
    ExitFunction();
}


#pragma mark -
#pragma mark Alert view delegate methods

// This view controller also works as a delegate for the 
// various alert views used during handling of the objects.
//
// This method is called when the user clicks a button on an alert
// view. If it was the OK button, we just call the actual mehtods
// that do the real work.
- (void)alertView: (UIAlertView *)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{ 
    EnterFunction();
    
    if ( alertView.tag == ALERT_VIEW_TAG_RENAME_FOLDER_CONTENT ) {
        
        NSIndexPath *indexPath = [alertUserInfo valueForKey: @"indexPath"];
        
        if ( buttonIndex == 1 ) {
            NSString *nameEntered = [[alertView textFieldAtIndex:0] text];
            
            // Get the index path of the object to rename out of the 
            // alertUserInfo ivar, then set it to nil to 
            // return to its neutral state.
            
            [self renameFolderContentAtIndex:indexPath.row toName:nameEntered];
                        
            // Make sure the table view is updated with the new name
            NSArray *array = [NSArray arrayWithObject: indexPath];
            [self.tableView reloadRowsAtIndexPaths: array
                                  withRowAnimation: UITableViewRowAnimationNone];
            
            // reloadRowsAtIndexPaths:withRowAnimation: makes
            // the tableView lose its selection, so we re-select it.
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            
            // Debatable whether it should be deselected.
            //
            // [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    // Reset the alert userInfo structure.
    alertUserInfo = nil;
    
    ExitFunction();    
}


- (BOOL)alertViewShouldEnableFirstOtherButton: (UIAlertView *)alertView
{
    EnterFunction();
    
    BOOL answer;
    if ( alertView.tag == ALERT_VIEW_TAG_RENAME_FOLDER_CONTENT ) {
        answer = [[[alertView textFieldAtIndex:0] text] length] > 0;
    }
    else {
        answer = YES;
    }
    
    ExitFunction();
    
    return answer;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    EnterFunction();

    ExitFunction();

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EnterFunction();

    ExitFunction();

    return self.folder.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    FolderContent *folderContent = [self.contentsOrdered objectAtIndex:indexPath.row];
    
    cell.textLabel.text = folderContent.title;
    
    ExitFunction();

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();

    // Configure the nav bar (some buttons are enabled based on
    // whether there is a selection or not.
    
    if ( [currentSelectedIndexPath isEqual:indexPath] ) {
        // Selecting the same row a second time de-selects it.
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        currentSelectedIndexPath = nil;
    }
    else {
        currentSelectedIndexPath = indexPath;
    }
    
    [self configureNavBar];

    ExitFunction();
}


/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnterFunction();
    
    ExitFunction();

    return 100.0f;
}
*/


#pragma mark - Split view controller delegate methods

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{    
    EnterFunction();
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;

    folderBarButtonItem = barButtonItem;
    
    [self configureNavBar];

    ExitFunction();
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    EnterFunction();

    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
    
    folderBarButtonItem = nil;

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
    
    // Set a predicate corresponding to the search
    
    NSPredicate *p = nil;
    if (self.searchBar.text && self.searchBar.text.length > 0)
    {
        p =[NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"title", self.searchBar.text];
    }    
    
    // Apply the predicate to the folder content
    
    // ...
        
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
