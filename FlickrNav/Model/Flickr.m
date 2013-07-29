//
// Created by Artem Vysotsky on 7/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Flickr.h"
#import "RestKit.h"
#import "FlickrPhoto.h"


@implementation Flickr

NSString *const apiKey = @"c3197551e3e12e727f1755e6a9fb01ad";
NSString *const urlTemplate = @"http://ycpi.api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&format=json&nojsoncallback=1&per_page=%d&page=%d";

- (id)init {

    self = [super init];

    if (self != nil) {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[FlickrPhoto class]];
        [mapping addAttributeMappingsFromDictionary:@{
                @"id" : @"id",
                @"title" : @"title",
                @"server" : @"server",
                @"secret" : @"secret",
                @"farm" : @"farm"
        }];

        self.perPage = 30;
        self.page = 0;

        self.responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:nil keyPath:@"photos.photo" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    }

    return self;
}

- (void)getFirstPage:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock {
    self.page = 0;
    [self search:self.searchTerm page:self.page perPage:self.perPage successBlock:successBlock errorBlock:errorBlock];
}

- (void)getNextPage:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock {
    self.page++;
    [self search:self.searchTerm page:self.page perPage:self.perPage successBlock:successBlock errorBlock:errorBlock];
}

- (void)search:(NSString *)term page:(NSUInteger)page perPage:(NSUInteger)perPage successBlock:(RKSuccessBlock)successBlock errorBlock:(RKErrorBlock)errorBlock; {
    NSString *urlString = [NSString stringWithFormat:urlTemplate, apiKey, [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], perPage, page];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[self.responseDescriptor]];
    [operation setCompletionBlockWithSuccess:successBlock failure:errorBlock];
    [operation start];
}
@end
