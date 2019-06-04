
package com.reactlibrary;

import java.util.List;

import android.os.Bundle;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.indooratlas.android.sdk.IALocation;
import com.indooratlas.android.sdk.IALocationListener;
import com.indooratlas.android.sdk.IAWayfindingListener;
import com.indooratlas.android.sdk.IAWayfindingRequest;
import com.indooratlas.android.sdk.IALocationManager;
import com.indooratlas.android.sdk.IALocationRequest;
import com.indooratlas.android.sdk.IARegion;
import com.indooratlas.android.sdk.IARoute;

public class RNIndoorManagerModule extends ReactContextBaseJavaModule {

  private IALocationManager locationManager;

  public RNIndoorManagerModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  private void sendEvent(ReactContext reactContext,
                         String eventName,
                         @Nullable WritableMap params) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }

  @ReactMethod
  public void initService(String apiKey, String apiSecret) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        locationManager = IALocationManager.create(getReactApplicationContext());
//        locationManager.registerRegionListener(new IARegion.Listener() {
//          @Override
//          public void onEnterRegion(IARegion iaRegion) {
//            String id = iaRegion.getId();
//            WritableMap params = Arguments.createMap();
//            params.putString("id", id);
//            sendEvent(getReactApplicationContext(), "enterRegion", params);
//          }
//
//          @Override
//          public void onExitRegion(IARegion iaRegion) {
//            String id = iaRegion.getId();
//            WritableMap params = Arguments.createMap();
//            params.putString("id", id);
//            sendEvent(getReactApplicationContext(), "exitRegion", params);
//          }
//        });

        locationManager.requestLocationUpdates(IALocationRequest.create(), new IALocationListener() {
          @Override
          public void onLocationChanged(IALocation location) {
            WritableMap params = Arguments.createMap();
            params.putDouble("latitude", location.getLatitude());
            params.putDouble("longitude", location.getLongitude());
            params.putDouble("altitude", location.getAltitude());
            params.putInt("floor", location.getFloorLevel());
            params.putDouble("horizontalAccuracy", location.toLocation().getAccuracy());
            params.putDouble("verticalAccuracy", location.toLocation().getVerticalAccuracyMeters());
//            params.putString("atlasId", location.getRegion().getId());
            sendEvent(getReactApplicationContext(), "locationChanged", params);
          }

          @Override
          public void onStatusChanged(String s, int i, Bundle bundle) {

          }
        });

      }
    });
  }

  @ReactMethod
  public void startWayfinding(final double latitude, final double longitude, final int floor) {
    getCurrentActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        IAWayfindingRequest wayfindingRequest = new IAWayfindingRequest.Builder()
                .withFloor(floor) // destination floor number
                .withLatitude(latitude) // destination latitude
                .withLongitude(longitude) // destination longitude
                .build();

        locationManager.requestWayfindingUpdates(wayfindingRequest, new IAWayfindingListener() {
          @Override
          public void onWayfindingUpdate(IARoute iaRoute) {
            WritableMap route = Arguments.createMap();
            WritableArray legs = Arguments.createArray();
            for (int i = 0; i < iaRoute.getLegs().size(); i++) {
              WritableMap begin = Arguments.createMap();
              begin.putDouble("longitude", iaRoute.getLegs().get(i).getBegin().getLongitude());
              begin.putDouble("latitude", iaRoute.getLegs().get(i).getBegin().getLatitude());
              begin.putDouble("floor", iaRoute.getLegs().get(i).getBegin().getFloor());
              begin.putDouble("nodeIndex", iaRoute.getLegs().get(i).getBegin().getNodeIndex());

              WritableMap end = Arguments.createMap();
              end.putDouble("longitude", iaRoute.getLegs().get(i).getEnd().getLongitude());
              end.putDouble("latitude", iaRoute.getLegs().get(i).getEnd().getLatitude());
              end.putDouble("floor", iaRoute.getLegs().get(i).getEnd().getFloor());
              end.putDouble("nodeIndex", iaRoute.getLegs().get(i).getEnd().getNodeIndex());

              WritableMap leg = Arguments.createMap();
              leg.putMap("begin", begin);
              leg.putMap("end", end);
              leg.putDouble("length", iaRoute.getLegs().get(i).getLength());
              leg.putDouble("direction", iaRoute.getLegs().get(i).getDirection());
              leg.putInt("edgeIndex", iaRoute.getLegs().get(i).getEdgeIndex());

              legs.pushMap(leg);
            }

            route.putArray("route", legs);
            sendEvent(getReactApplicationContext(), "didUpdateRoute", route);
          }
        });
      }
    });
  }

  @Override
  public String getName() {
    return "RNIndoorManager";
  }
}