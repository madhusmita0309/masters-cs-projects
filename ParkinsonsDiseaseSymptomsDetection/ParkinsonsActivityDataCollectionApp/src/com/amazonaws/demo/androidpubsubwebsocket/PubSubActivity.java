/**
 * Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * <p>
 * http://aws.amazon.com/apache2.0
 * <p>
 * This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
 * OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and
 * limitations under the License.
 */

package com.amazonaws.demo.androidpubsubwebsocket;

import android.app.Activity;
import android.hardware.SensorEventListener;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.amazonaws.auth.CognitoCachingCredentialsProvider;
import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobile.client.Callback;
import com.amazonaws.mobile.client.UserStateDetails;
import com.amazonaws.mobile.client.results.SignInResult;
import com.amazonaws.mobileconnectors.iot.AWSIotMqttClientStatusCallback;
import com.amazonaws.mobileconnectors.iot.AWSIotMqttManager;
import com.amazonaws.mobileconnectors.iot.AWSIotMqttNewMessageCallback;
import com.amazonaws.mobileconnectors.iot.AWSIotMqttQos;
import com.amazonaws.regions.Regions;

import org.w3c.dom.Text;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;

public class PubSubActivity extends Activity implements SensorEventListener {

    String activity="1";
    String tremor="-1";
    static final String LOG_TAG = PubSubActivity.class.getCanonicalName();

    Sensor accelerometer;
    Sensor gyroscope;
    Sensor gravity;
    Sensor rotationVec;
    SensorManager sm;


    // --- Constants to modify per your configuration ---

    // Customer specific IoT endpoint
    // AWS Iot CLI describe-endpoint call returns: XXXXXXXXXX.iot.<region>.amazonaws.com,
    private static final String CUSTOMER_SPECIFIC_IOT_ENDPOINT = "a9l6aqqkdziop-ats.iot.ap-northeast-1.amazonaws.com";



//    EditText txtSubscribe;
    final String accTopic="parkinsons/acc";
    final String gyroTopic="parkinsons/gyro";
    final String gravTopic="parkinsons/grav";
    final String rotTopic="parkinsons/rot";

    String sensorReading="{\r\n  \"DeviceID\": \"Androind_Entry\",\r\n  \"X\": \"180\",\r\n  \"Y\": \"80\"\r\n}";
    TextView txtMessage;

    TextView tvLastMessage;
    TextView tvClientId;
    TextView tvStatus;

    Button btnConnect;

    AWSIotMqttManager mqttManager;
    String clientId;
    String sessionId;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        
        tvClientId = findViewById(R.id.tvClientId);
        tvStatus = findViewById(R.id.tvStatus);

        btnConnect = findViewById(R.id.btnConnect);
        btnConnect.setEnabled(false);

        clientId = UUID.randomUUID().toString();
        tvClientId.setText(clientId);

        sessionId=clientId;

        Log.d(LOG_TAG, "Getting Sensors ");
        sm = (SensorManager)getSystemService(SENSOR_SERVICE);

        accelerometer=sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        sm.registerListener(this,accelerometer,SensorManager.SENSOR_DELAY_NORMAL);
        Log.d(LOG_TAG, "onCreate: Registered Accelerometer Listener ");

        gyroscope=sm.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
        gravity = sm.getDefaultSensor(Sensor.TYPE_GRAVITY);
        rotationVec=sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);



        sm.registerListener(this,gyroscope,SensorManager.SENSOR_DELAY_NORMAL);
        Log.d(LOG_TAG, "onCreate: Registered Gyroscope Listener ");

        sm.registerListener(this,gravity,SensorManager.SENSOR_DELAY_NORMAL);
        Log.d(LOG_TAG, "onCreate: Registered GravitySensor Listener ");

        sm.registerListener(this,rotationVec,SensorManager.SENSOR_DELAY_NORMAL);
        Log.d(LOG_TAG, "onCreate: Registered RotationVector Sensor Listener ");



        // Initialize the credentials provider
        final CountDownLatch latch = new CountDownLatch(1);
        AWSMobileClient.getInstance().initialize(
                getApplicationContext(),
                new Callback<UserStateDetails>() {
                    @Override
                    public void onResult(UserStateDetails userStateDetails)
                    {
                        Log.i(LOG_TAG, "onResult: " + userStateDetails.getUserState());

                        try {

                            Map<String, String> userAttributes = AWSMobileClient.getInstance().getUserAttributes();
                            Log.d(LOG_TAG, "userAttributes: " + Arrays.toString(userAttributes.entrySet().toArray()));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        latch.countDown();
                    }

                    @Override
                    public void onError(Exception e) {
                        latch.countDown();
                        Log.e(LOG_TAG, "onError: ", e);
                    }
                }
        );

        try {
            latch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // MQTT Client
        mqttManager = new AWSIotMqttManager(clientId, CUSTOMER_SPECIFIC_IOT_ENDPOINT);

        // Enable button once all clients are ready
        btnConnect.setEnabled(true);
    }


    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    public void onSensorChanged(SensorEvent event) {

        SensorEvent gyro;
        SensorEvent gravity;
        SensorEvent rotation;
        String msg;
        //int countgyro=0;

        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            //updateAccelParams(event.values[0], event.values[1], event.values[2]);
            Log.d(LOG_TAG, "Accelerometer readings :" + event.values[0] + " " + event.values[1] + " " + event.values[2] );
            Log.d(LOG_TAG, "Current time  " + System.currentTimeMillis());
            String sensorReading="{\r\n  \"DeviceID\": \""+sessionId+"\",\r\n  \"timeStamp\": \""+System.currentTimeMillis()+"\",\r\n  \"accX\": \""+event.values[0]+"\",\r\n  \"accY\": \""+event.values[1]+"\",\r\n  \"accZ\": \""+event.values[2]+"\",\r\n  \"Activity\": \""+activity+"\",\r\n  \"Tremor\": \""+tremor+"\"}";
            publish(accTopic,sensorReading);
        }

        if (event.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            gyro = event;
            Log.d(LOG_TAG, "Gyroscope readings :" + gyro.values[0] + " " + gyro.values[1] + " " + gyro.values[2] );
            Log.d(LOG_TAG, "Current time  " + System.currentTimeMillis());
            String sensorReading="{\r\n  \"DeviceID\": \""+sessionId+"\",\r\n  \"timeStamp\": \""+System.currentTimeMillis()+"\",\r\n  \"gyroX\": \""+gyro.values[0]+"\",\r\n  \"gyroY\": \""+gyro.values[1]+"\",\r\n  \"gyroZ\": \""+gyro.values[2]+"\",\r\n  \"Activity\": \""+activity+"\",\r\n  \"Tremor\": \""+tremor+"\"}";
            publish(gyroTopic,sensorReading);
            //countgyro++

        }

        if (event.sensor.getType() == Sensor.TYPE_GRAVITY) {
            gravity = event;
            Log.d(LOG_TAG, "Gravity readings :" + gravity.values[0] + " " + gravity.values[1] + " " + gravity.values[2]);
            Log.d(LOG_TAG, "Current time  " + System.currentTimeMillis());
            String sensorReading="{\r\n  \"DeviceID\": \""+sessionId+"\",\r\n  \"timeStamp\": \""+System.currentTimeMillis()+"\",\r\n  \"gravX\": \""+gravity.values[0]+"\",\r\n  \"gravY\": \""+gravity.values[1]+"\",\r\n  \"gravZ\": \""+gravity.values[2]+"\",\r\n  \"Activity\": \""+activity+"\",\r\n  \"Tremor\": \""+tremor+"\"}";
            publish(gravTopic,sensorReading);

        }

        if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {
            rotation = event;
            Log.d(LOG_TAG, "Rotation Vector readings :" + rotation.values[0] + " " + rotation.values[1] + " " + rotation.values[2] + " " + rotation.values[3] + " " + rotation.values[4]);
            Log.d(LOG_TAG, "Current time  " + System.currentTimeMillis());
            String sensorReading="{\r\n  \"DeviceID\": \""+sessionId+"\",\r\n  \"timeStamp\": \""+System.currentTimeMillis()+"\",\r\n  \"rotX\": \""+rotation.values[0]+"\",\r\n  \"rotY\": \""+rotation.values[1]+"\",\r\n  \"rotZ\": \""+rotation.values[2]+"\",\r\n  \"angle\": \""+rotation.values[3]+"\",\r\n  \"Activity\": \""+activity+"\",\r\n  \"Tremor\": \""+tremor+"\"}";
            publish(rotTopic,sensorReading);
        }
    }



    public void connect(final View view) {
        Log.d(LOG_TAG, "clientId = " + clientId);
//        sessionId++;

        try {
            mqttManager.connect(AWSMobileClient.getInstance(), new AWSIotMqttClientStatusCallback() {
                @Override
                public void onStatusChanged(final AWSIotMqttClientStatus status,
                                            final Throwable throwable) {
                    Log.d(LOG_TAG, "Status = " + String.valueOf(status));
                    //subscribe(accTopic);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            tvStatus.setText(status.toString());
                            if (throwable != null) {
                                Log.e(LOG_TAG, "Connection error.", throwable);

                            }


                        }
                    });
                }
            });
        } catch (final Exception e) {
            Log.e(LOG_TAG, "Connection error.", e);
            tvStatus.setText("Error! " + e.getMessage());
        }

    }


    public void publish(String topic, String msg) {
        try {
            mqttManager.publishString(msg, topic, AWSIotMqttQos.QOS0);
            //txtMessage.setText(msg);
        } catch (Exception e) {
            Log.e(LOG_TAG, "Publish error.", e);
        }
    }

    public void disconnect(final View view) {
        try {
            mqttManager.disconnect();
        } catch (Exception e) {
            Log.e(LOG_TAG, "Disconnect error.", e);
        }
    }
}
