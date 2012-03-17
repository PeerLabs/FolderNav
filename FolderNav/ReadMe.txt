FolderNav



Folder types

There are two main categories of folders:

 1) Permanent folders
    - Current Unfiled
    - Drafts
    - Trash
    
 2) User defined folders
    These folders are created and named by the user
   


Folders storage

Folders are stored in Core Data, and the app is responsible for the 
initial creation and population of the database with the permanent
folders. 

The persistent folders cannot be renamed or deleted, and this is 
enforced by the cope of the app.

Each folder is represented by an object that has an ivar "type". 

type is either a predefined string identifying it as one of the 
permanent folders, or a string identifying it as a user-defined
one.

This ivar is also used by specific sorting code, which ensures that 
the permanent folders are displayed first on the list, followed by
the user defined folders, ordered alphabetically by name.

The sorting defining the ordering as seen by the user is programmed
in the method -makeFetchRequest: of the class MasterViewController.


Definition of permanent folders

The permanent folders are defined in the method -application:didFinishLaunchingWithOptions:
of AppDelegate, and they are created in -setupFolders in the same
class.

The permanent folder types are kept in a read-only property of 
AppDelegate, "permanentFolderTypes".

This read-only property is used by other classes in the app to 
make sure the special treatment of the permanent folders work
as expected.



Ho to add new permanent folders to the boiler plate code

To add a new permanent folder to the app, just add it in application:didFinishLaunchingWithOptions: 
and make sure it is created in -setupFolders.

The reason for the split is that the list of permanent folders is 
always needed, while the setup should only be needed the first time
the app is launched.

However, as a robustness precaution, the presence is checked at every 
launch, and if any of the folders are missing, they are re-created as
they were at the first launch of the app.
