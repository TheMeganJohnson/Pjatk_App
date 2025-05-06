package com.example.emulator_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class NFCReceiver extends BroadcastReceiver {
    private static final String TAG = "NFCReceiver";
    public static final String ACTION_UPDATE_TOKEN = "com.example.emulator_app.UPDATE_TOKEN";
    public static final String EXTRA_TOKEN = "TOKEN";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (ACTION_UPDATE_TOKEN.equals(intent.getAction())) {
            String newToken = intent.getStringExtra(EXTRA_TOKEN);
            Log.d(TAG, "Received new Token: " + newToken);
            NFCEmulatorService.updateToken(newToken);
        }
    }
}