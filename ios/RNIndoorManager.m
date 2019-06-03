
#import "RNIndoorManager.h"

@implementation RNIndoorManager
RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"locationChanged", @"didUpdateRoute"];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(initService: (NSString *)apiKey apiSecret:(NSString *)apiSecret) {
    self.locationManager = [IALocationManager sharedInstance];
    self.locationManager.delegate = self;
    [self.locationManager setApiKey:apiKey andSecret:apiSecret];
	[self.locationManager startUpdatingLocation];
	NSString *verStr = IALocationManager.versionString;
	NSLog([NSString stringWithFormat:@"%@, %@", @"IA version:", verStr]);
}

RCT_EXPORT_METHOD(requestWayFinding: (nonnull NSNumber *)latitude longitude: (nonnull NSNumber *)longitude floor: (nonnull NSNumber *)floor) {
	IAWayfindingRequest *request = [[IAWayfindingRequest alloc] init];
	request.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
	request.floor = 1;
	[self.locationManager startMonitoringForWayfinding:request];
}

RCT_EXPORT_METHOD(stopWayFinding) {
	[self.locationManager stopMonitoringForWayfinding];
}

- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    (void) manager;
    CLLocation *l = [(IALocation *)locations.lastObject location];
//    IARegion *f = [(IALocation *)locations.lastObject region];
	
	NSLog(@"position changed to coordinate: %.6fx%.6f", l.coordinate.latitude, l.coordinate.longitude);
//    if ([f type] == kIARegionTypeFloorPlan) {
        [self sendEventWithName:@"locationChanged" body:@{@"lat": [NSNumber numberWithDouble:l.coordinate.latitude],
                                                          @"lng": [NSNumber numberWithDouble:l.coordinate.longitude],
//                                                          @"atlasId": [f identifier]
                                                          }];
//    }
}

- (void)indoorLocationManager:(IALocationManager *)manager didUpdateRoute:(IARoute *)route {
	(void) manager;
//	NSMutableArray *r = [[NSMutableArray alloc] init];
	NSObject *r = (NSObject *)route;
//	for (int i = 0; i < [route.legs count]; i++)
//	{
//		NSDictionary *beginPt = @{
//			@"lng" : @(route.legs[i].begin.coordinate.longitude)
//		};
//		NSDictionary *leg = @{
//			@"begin" : beginPt
//		};
//	}
	
	[self sendEventWithName:@"didUpdateRoute" body:r];
}

@end
