//
// Created by Artem Vysotsky on 7/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

typedef void (^RKSuccessBlock)(RKObjectRequestOperation *operation, RKMappingResult *result);

typedef void (^RKErrorBlock)(RKObjectRequestOperation *operation, NSError *error);

@interface Flickr : NSObject
@property(nonatomic, strong) RKResponseDescriptor *responseDescriptor;
@property(nonatomic, strong) NSString *searchTerm;
@property(nonatomic) NSUInteger perPage;
@property(nonatomic) NSUInteger page;

- (id)init;

- (void)getFirstPage:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock;

- (void)getNextPage:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock;

- (void)search:(NSString *)term page:(NSUInteger)page perPage:(NSUInteger)perPage successBlock:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock;
@end