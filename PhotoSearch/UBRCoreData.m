//
//  UBRCoreData.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/27/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRCoreData.h"
#import "UBRSearchTerm.h"

@implementation UBRCoreData

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

/*
 save search term
 */
- (void)saveSearchTerm:(NSString *)searchTerm
{
    //save on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        //set basic variables
        NSManagedObjectContext *context = [self managedObjectContextForThread];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:context];
    
        //fetch previous search result
        NSFetchRequest * previousSearchResult= [[NSFetchRequest alloc] init];
        [previousSearchResult setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(searchTerm = %@)",searchTerm];
        [previousSearchResult setPredicate:predicate];
        [previousSearchResult setIncludesPropertyValues:YES]; //only fetch the managedObjectID
        
        NSError *error = nil;
        NSArray *searchResultFromDatabase = [context executeFetchRequest:previousSearchResult error:&error];
        
        if(!error){
            //if there's a match in the database, update object
            if([searchResultFromDatabase count] == 1){
                NSManagedObject *object = [searchResultFromDatabase firstObject];
                [object setValue:[NSDate date] forKey:@"lastPerformed"];
                [self  saveContextWithManagedObjectContext:context];
            }
            //if there isn't a match in the database, create a new object
            else if([searchResultFromDatabase count] == 0){
                NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
                [object setValue:searchTerm forKey:@"searchTerm"];
                [object setValue:[NSDate date] forKey:@"lastPerformed"];
                [self saveContextWithManagedObjectContext:context];
            }
            else{
                //error
            }
        }
        
    });
    
}

/*
 fetch previous search terms
 */
- (void)fetchPreviousSearchTermsWithNewSearchTerm:(NSString *)newSearchTerm completionBlock:(void(^)(NSArray *searchTerms, NSString *searchTerm))complectionBlock
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        //set context and fetch request
        NSManagedObjectContext *context = [self managedObjectContextForThread];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        //set object
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:context];
        [request setEntity:entity];
        
        //set predicate, if there is a search term
        if([newSearchTerm length] > 0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(searchTerm CONTAINS %@)",newSearchTerm];
            [request setPredicate:predicate];
        }
        
        //order by lastPerformed, most recent search result first
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"lastPerformed" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
        [request setSortDescriptors:sortDescriptors];
        
        //results
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        NSMutableArray *convertedSearchResults = [NSMutableArray new];
        
        for(NSManagedObject *object in results){
            
            UBRSearchTerm *searchResult = [[UBRSearchTerm alloc] initWithDictionary:@{@"searchTerm":[object valueForKey:@"searchTerm"],
                                                                                         @"lastPerformed":[object valueForKey:@"lastPerformed"]}];
            [convertedSearchResults addObject:searchResult];
            
        }
        
        //if there are search results, return array
        if([convertedSearchResults count] > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                complectionBlock([convertedSearchResults copy],newSearchTerm);
            });
        }
        //if there are no search results, return empty array
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                complectionBlock([NSArray new],newSearchTerm);
            });
        }
        
    });
    
}



#pragma mark - Core Data stack
/*
 save conext on specific managed object context
 */
- (void)saveContextWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

// Returns the managed object context for the application for a particular thread.
- (NSManagedObjectContext *)managedObjectContextForThread
{
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext *threadManagedObjectContext;
    if (coordinator != nil) {
        threadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [threadManagedObjectContext setPersistentStoreCoordinator:coordinator];
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType];
        [threadManagedObjectContext setMergePolicy:mergePolicy];
    }
    return threadManagedObjectContext;
    
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoSearch" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
