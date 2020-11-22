package com.topfreelancerdeveloper.flutter_openvpn_example;

import android.content.Intent;

import com.topfreelancerdeveloper.flutter_openvpn.FlutterOpenvpnPlugin;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == 1) {
            if (resultCode == RESULT_OK) {
                FlutterOpenvpnPlugin.setPermission(true);
            } else {
                FlutterOpenvpnPlugin.setPermission(false);
            }
        }
    }
}
