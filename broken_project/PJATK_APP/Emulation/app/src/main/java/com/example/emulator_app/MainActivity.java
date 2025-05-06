package com.example.emulator_app;

import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.emulator_app/nfc";
    private static final String TOKEN_CHANNEL = "com.example.emulator_app/token";
    private EventChannel.EventSink tokenEventSink;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("updateToken")) {
                                String token = call.argument("token");
                                Intent intent = new Intent(NFCReceiver.ACTION_UPDATE_TOKEN);
                                intent.putExtra(NFCReceiver.EXTRA_TOKEN, token);
                                sendBroadcast(intent);
                                result.success(null);
                            } else {
                                result.notImplemented();
                            }
                        }
                );

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), TOKEN_CHANNEL)
                .setStreamHandler(
                        new EventChannel.StreamHandler() {
                            @Override
                            public void onListen(Object arguments, EventChannel.EventSink events) {
                                tokenEventSink = events;
                            }

                            @Override
                            public void onCancel(Object arguments) {
                                tokenEventSink = null;
                            }
                        }
                );
    }

    public void sendTokenToFlutter(String token) {
        if (tokenEventSink != null) {
            tokenEventSink.success(token);
        }
    }
}