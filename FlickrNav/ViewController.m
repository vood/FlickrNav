//
//  ViewController.m
//  FlickrNav
//
//  Created by Artem Vysotsky on 7/28/13.
//  Copyright (c) 2013 Artem Vysotsky. All rights reserved.
//

#import "ViewController.h"
#import "RestKit.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) Flickr *flickrClient;
@property(nonatomic, strong) NSMutableArray *searchResults;
@property(nonatomic, strong) GCDAsyncSocket *listenSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResults = [@[] mutableCopy];
    UIImage *image = [UIImage imageNamed:@"bg.jpg"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [self.searchBar setBackgroundImage:image];
    self.flickrClient = [[Flickr alloc] init];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:9999 error:&error]) {
        NSLog(@"I goofed: %@", error);
    }


    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.flickrClient.searchTerm = searchBar.text;
    [self loadFirstPage];
    [self.searchBar resignFirstResponder];
}

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.searchResults count];
}


// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cell.photo = self.searchResults[indexPath.row];
    });

    if (indexPath.row + 1 == [self.searchResults count]) {
        [self loadNexPage];
    }

    return cell;
}

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 150);
}

// 3
- (UIEdgeInsets)                   collectionView:
        (UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(UIRefreshControl *)sender {
    [self loadFirstPage];
    [sender endRefreshing];
}

- (void)loadFirstPage {
    [self.flickrClient getFirstPage:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:[result array]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }                    errorBlock:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);

    }];
}

- (void)loadNexPage {
    [self.flickrClient getNextPage:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray *newResults = [result array];
        if ([newResults count]) {
            int resultsSize = [self.searchResults count];
            [self.searchResults addObjectsFromArray:newResults];
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            for (int i = resultsSize; i < resultsSize + newResults.count; i++) {
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
            });
        }
    }                   errorBlock:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);

    }];
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    newSocket.delegate = self;
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag {
    NSString *term = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.searchBar.text = term;
    self.flickrClient.searchTerm = term;
    [self loadFirstPage];
    [sender readDataWithTimeout:-1 tag:0];
}


@end