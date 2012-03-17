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

#define ALERT_VIEW_TAG_RENAME_FOLDER_CONTENT 1

@interface FolderContentsViewController () 

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *contentsOrdered;

- (void)configureView;
@end

@implementation FolderContentsViewController {
    // "Private" ivars
    NSDictionary *alertUserInfo;
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
                
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
    
    ExitFunction();
}

- (void)configureView
{
    EnterFunction();
    // Update the user interface for the detail item.

    if (self.folder) {
        
        self.contentsOrdered = [[_folder contents] sortedArrayUsingDescriptors: [self alphabeticalSortDescriptors]];

        [self.tableView reloadData];
    }
    else {
        self.contentsOrdered = [NSArray array];
    }
    
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
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Re-configure view to reflect change
    [self configureView];
    
    ExitFunction();    
}

- (void)renameObject: (id)sender
{
    EnterFunction();
    
    // When editing, selection means rename
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    //FolderContent *folderContent = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
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
    FolderContent *fc = [self.contentsOrdered objectAtIndex:row];
    
    fc.title = newName;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (void)deleteObject: (id)sender
{
    EnterFunction();

    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSUInteger selectedRow = self.tableView.indexPathForSelectedRow.row;
    
    FolderContent *objectToDelete = [self.contentsOrdered objectAtIndex:selectedRow];
    
    [self.folder removeContentsObject: objectToDelete];
        
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
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
            
            NSLog(@"Folder renamed to: %@", nameEntered);
            
            // Make sure the table view is updated with the new name
            NSArray *array = [NSArray arrayWithObject: indexPath];
            [self.tableView reloadRowsAtIndexPaths: array
                                  withRowAnimation: UITableViewRowAnimationNone];
        }
        else {
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    ExitFunction();
}



#pragma mark - Split view controller delegate methods

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{    
    EnterFunction();
    
    NSString *folderTitle = NSLocalizedString(@"Folders", @"Default text on folder button in portrait view");
    
    barButtonItem.title = folderTitle;
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;

    ExitFunction();
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    EnterFunction();

    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;

    ExitFunction();
}

@end
