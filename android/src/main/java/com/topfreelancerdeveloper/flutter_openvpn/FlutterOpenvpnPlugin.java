package com.topfreelancerdeveloper.flutter_openvpn;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

import de.blinkt.openvpn.core.OpenVPNService;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.service.ServiceAware;
import io.flutter.embedding.engine.plugins.service.ServicePluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import de.blinkt.openvpn.OboloiVPN;
import de.blinkt.openvpn.onPermissionChanged;
import de.blinkt.openvpn.OnVPNStatusChangeListener;

/** FlutterOpenvpnPlugin */

enum VpnStatus {
   ProfileLoaded("profileloaded") {
   },
  ProfileLoadFailed("profileloadfailed") {
  };
   public String callMethod;
   VpnStatus(String callMethod) {
     this.callMethod = callMethod;
   }
}
public class FlutterOpenvpnPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, ServiceAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static  OboloiVPN vpn;
  static private Activity activity;
  public static void setPermission(boolean permit) {
    if(vpn != null) vpn.onPermissionChanged(permit);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_openvpn");
    channel.setMethodCallHandler(this);
  }


  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_openvpn");
    channel.setMethodCallHandler(new FlutterOpenvpnPlugin());
    activity = registrar.activity();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, final @NonNull Result result) {
    try {
      if (call.method.equals("getPlatformVersion")) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
      } else if (call.method.equals("init")) {
        vpn = new OboloiVPN(activity);
        HashMap<String,String> response = new HashMap<>();
        response.put("currentStatus" , OpenVPNService.getStatus());
        response.put("expireAt" , OpenVPNService.getExpireAt());
        result.success(response);
      } else if(call.method.equals("lunch")){
        String config = call.argument("ovpnFileContent");
        String expireAt = call.argument("expireAt");
        String user = call.argument("user");
        String pass = call.argument("pass");
        if(vpn == null) {
          result.error("-1", "OpenVpnPlugin not initialized", null);
          return;
        }
        if(config == null || config.isEmpty()){
          result.error("-2", "Null or Empty Vpn Config", null);
          return;
        }
        vpn.setOnVPNStatusChangeListener(new OnVPNStatusChangeListener() {
          @Override
          public void onProfileLoaded(boolean profileLoaded) {
            channel.invokeMethod(profileLoaded ? VpnStatus.ProfileLoaded.callMethod : VpnStatus.ProfileLoadFailed.callMethod , null);
            if(profileLoaded){ vpn.init(); result.success(null);}
          }

          @Override
          public void onVPNStatusChanged(String status) {
            channel.invokeMethod(status , null);
          }

          @Override
          public void onConnectionStatusChanged(String duration , String  lastPacketRecieve , String byteIn , String byteOut) {
            HashMap<String,String> response = new HashMap<>();
            response.put("duration" ,duration);
            response.put("lastPacketRecieve" , lastPacketRecieve);
            response.put("byteIn" , byteIn);
            response.put("byteOut" , byteOut);
            channel.invokeMethod("connectionUpdate" , response);
          }
        });
        vpn.launchVPN(config , expireAt, user, pass);


      }else if(call.method.equals("stop")){
        vpn.init();
        result.success(null);
      }
    }catch (Exception err){
      result.error("-10",err.toString(),"UnExpected error");
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public void onAttachedToService(@NonNull ServicePluginBinding binding) {

  }

  @Override
  public void onDetachedFromService() {

  }
}
