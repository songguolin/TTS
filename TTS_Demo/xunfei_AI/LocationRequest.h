//
//  LocationRequest.h
//  MSCDemo
//
//  Created by 侯效林 on 2017/5/31.
//
//

#ifndef LocationRequest_h
#define LocationRequest_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



@interface LocationRequest : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *iFlyLocManager;
}

//request location info
- (void)locationAsynRequest;

//get location info
-(CLLocation *) getLocation;

@end


#endif /* LocationRequest_h */
