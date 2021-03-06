//
//  PhotoGalleryViewController.m
//  burn-ios-app
//
//  Created by Anita Santoso on 13/10/13.
//  Copyright (c) 2013 burn. All rights reserved.
//

#import "PhotoGalleryViewController.h"
#import "PhotoViewController.h"
#import "StoryboardUtil.h"
#import "LoadingView.h"
#import "EyeEmNetworkService.h"
#import "GeoCodeService.h"
#import "LocationManager.h"

@interface PhotoGalleryViewController ()
@property NSInteger lastLoadIndex;
@end

@implementation PhotoGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"What do you want to see?";
    
    self.lastLoadIndex = 0;
//    [[GeoCodeService sharedInstance]lookUpAddressFromCoordinate:[EyeEmNetworkService sharedInstance].currentLocation completion:^(NSString *location) {
//        self.title = location;
//    } error:^(NSString *errorMsg) {
//        
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.infoLabel.hidden = YES;
    cell.backgroundColor = [UIColor clearColor];
    Photo *photo = ((Photo*)[self.photos objectAtIndex:indexPath.row]);
    NSString *urlStr = photo.photoURL;

    if(photo.location.latitude) {
        [self showPhotoDetails:photo onLabel:cell.infoLabel];
    }
    [cell setImageURL:[NSURL URLWithString:urlStr]];
    return cell;
}

- (void)showPhotoDetails:(Photo*)photo onLabel:(UILabel*)label {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setMaximumFractionDigits:0];

    label.text = @"";
    if(!isnan(photo.location.latitude)) {
        double distanceInM = [self distanceBetweenLocationOrigin:[EyeEmNetworkService sharedInstance].currentLocation andDestination:photo.location];
        double calories = 400+[self caloriesBurnedForDistance:distanceInM/1000];
        photo.distancdeInM = floor(distanceInM);
        
        label.hidden = NO;
        label.text = [NSString stringWithFormat:@"%@m/%@cals", [formatter stringFromNumber:@(photo.distancdeInM)], [formatter stringFromNumber:@(calories)]];
    }
}

- (double)caloriesBurnedForDistance:(double)distance {
    // 230 calories in hour
    // 7km average per hour
    return distance/7*230;
}

- (double)distanceBetweenLocationOrigin:(CLLocationCoordinate2D)origin andDestination:(CLLocationCoordinate2D)destination {
    CLLocation *originLoc = [[CLLocation alloc]initWithLatitude:origin.latitude longitude:origin.longitude];
    
    CLLocation *destLoc = [[CLLocation alloc]initWithLatitude:destination.latitude longitude:destination.longitude];
    CLLocationDistance distance = [originLoc distanceFromLocation:destLoc]; // in meters
    return distance;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoViewController *viewCon = (PhotoViewController*)[StoryboardUtil
                                                          loadViewControllerWithID:@"PhotoView"];
    viewCon.photo = [self.photos objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(40, 10, 0, 10);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
