package com.example.emulator_app;

import android.content.Intent;
import android.nfc.cardemulation.HostApduService;
import android.os.Bundle;
import android.util.Log;

public class NFCEmulatorService extends HostApduService {
    private static final String TAG = "NFCEmulatorService";
    private static final String SELECT_APDU_HEADER = "00A40400";
    private static final String AID = "F0010203040506";
    private static final String RESPONSE_OK = "9000";
    private static final String RESPONSE_UNKNOWN = "0000";

    private static final String uid = "bebf0937-3fb9-4ef6-8ea6-90e107be4157";
    private static String token = null;

    @Override
    public byte[] processCommandApdu(byte[] apdu, Bundle extras) {
        String hexApdu = bytesToHex(apdu);
        Log.d(TAG, "Received APDU: " + hexApdu);

        if (hexApdu.startsWith(SELECT_APDU_HEADER + AID)) {
            if (token != null) {
                sendTokenToFlutter(token);
            }
            return hexStringToByteArray(uid + RESPONSE_OK);
        } else {
            // Simulate receiving a new token from the NFC reader
            token = "newTokenFromReader";
            sendTokenToFlutter(token);
            return hexStringToByteArray(RESPONSE_UNKNOWN);
        }
    }

    @Override
    public void onDeactivated(int reason) {
        Log.d(TAG, "Deactivated: " + reason);
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b));
        }
        return sb.toString();
    }

    private byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }

    public static void updateToken(String newToken) {
        token = newToken;
    }

    private void sendTokenToFlutter(String token) {
        Intent intent = new Intent("com.example.emulator_app.TOKEN_UPDATE");
        intent.putExtra("TOKEN", token);
        sendBroadcast(intent);
    }
}