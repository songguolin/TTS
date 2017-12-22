//
//  LocationRequest.m
//  MSCDemo
//
//  Created by 侯效林 on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "LocationRequest.h"

@implementation LocationRequest

static CLLocation * iFlyLocation = nil;


 //request location info
- (void)locationAsynRequest
{
     dispatch_async(dispatch_get_main_queue(), ^{
         
         if([CLLocationManager locationServicesEnabled]){
             
             if(iFlyLocManager == nil){
                 iFlyLocManager = [[CLLocationManager alloc] init];
                 iFlyLocation = nil;
             }
             
             iFlyLocManager.delegate = self;
             
              [iFlyLocManager requestWhenInUseAuthorization];
             
             iFlyLocManager.desiredAccuracy = kCLLocationAccuracyBest;
             [iFlyLocManager startUpdatingLocation];
         }
     });

}

//get location info
-(CLLocation *) getLocation
{
    return iFlyLocation;
}

- (void)locationManager:(CLLocationManager *)manager
 didUpdateLocations:(NSArray<CLLocation *> *)locations __OSX_AVAILABLE_STARTING(__MAC_10_9,__IPHONE_6_0);
{
     [iFlyLocManager stopUpdatingLocation];
     
     iFlyLocation = [locations lastObject];
 
     iFlyLocManager = nil;
}
- (void)locationManager:(CLLocationManager *)manager
didFailWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
}
@end
