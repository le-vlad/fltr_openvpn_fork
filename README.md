# flutter_openvpn

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


change minsdk to 22
add this to mainfast application tag
'
<service
            android:name="de.blinkt.openvpn.core.OpenVPNService"
            android:permission="android.permission.BIND_VPN_SERVICE">
            <intent-filter>
                <action android:name="android.net.VpnService"/>
            </intent-filter>
        </service>
        <service
            android:name="de.blinkt.openvpn.api.ExternalOpenVPNService"
            tools:ignore="ExportedService">

            <intent-filter>
                <action android:name="de.blinkt.openvpn.api.IOpenVPNAPIService"/>
            </intent-filter>
        </service>

        <activity
            android:name="de.blinkt.openvpn.LaunchVPN"
            android:excludeFromRecents="true"
            android:label="@string/vpn_launch_title"
            android:theme="@android:style/Theme.DeviceDefault.Light.Panel"
            tools:ignore="ExportedActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>

                <category android:name="android.intent.category.DEFAULT"/>
            </intent-filter>
        </activity>
'
needed permissons
'
<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
'