//
//  UBRCoreData.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/27/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBRCoreData : NSObject

//core data
@property (readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*
 save search term
 */
- (void)saveSearchTerm:(NSString *)searchTerm;

/*
 fetch previous search terms
 */
- (void)fetchPreviousSearchTermsWithNewSearchTerm:(NSString *)newSearchTerm completionBlock:(void(^)(NSArray *searchTerms, NSString *searchTerm))complectionBlock;

@end
