## *myo* - Nim bindings for the Thalmic Labs Myo gesture control armband SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

{.deadCodeElim: on.}


## These types and enumerations describe the format of data sent to and from a
## Myo device using Bluetooth Low Energy. All values are big-endian.

const
  myohwNumEmgSensors* = 8 ## The number of EMG sensors that a Myo has.

  myoServiceInfoUuid* = [
    0x42, 0x48, 0x12, 0x4a,
    0x7f, 0x2c, 0x48, 0x47,
    0xb9, 0xde, 0x04, 0xa9,
    0x01, 0x00, 0x06, 0xd5]

  myoServiceBaseUuid* = [
    0x42, 0x48, 0x12, 0x4a,
    0x7f, 0x2c, 0x48, 0x47,
    0xb9, 0xde, 0x04, 0xa9,
    0x00, 0x00, 0x06, 0xd5]

type
  MyohwServices* {.pure, size: sizeof(cint).} = enum
    ## 16bit short UUIDs of Myo services and characteristics.
    ##
    ## To construct a full 128bit UUID, replace the two 0x00 hex bytes of
    ## `myoServiceBaseUuid <#myoServiceBaseUuid>`_  with a short UUID from
    ## `MyohwStandardServices <#MyohwStandardServices>`_. The byte sequence of
    ## `myoServiceBaseUuid` is in network order. Keep this in mind when doing
    ## the replacement. For example, the full service UUID for GCControlService
    ## would be `d5060001-a904-deb9-4748-2c7f4a124842`.
    ControlService = 0x00000001,
      ## Myo info service.
    ImuDataService = 0x00000002,
      ## IMU service.
    ClassifierService = 0x00000003,
      ## Classifier event service.
    EmgDataService = 0x00000005,
      ## Raw EMG data service.
    MyoInfoCharacteristic = 0x00000101,
      ## Serial number for this Myo and various parameters which are specific to
      ## this firmware. Read-only attribute. See `MyohwFwInfo <#MyohwFwInfo>`_.
    classifierEventCharacteristic = 0x00000103,
      ## Classifier event data. Indicate-only characteristic.
      ## See `MyohwPose <#MyohwPose>`_.
    emgData0Characteristic = 0x00000105,
      ## Raw EMG data. Notify-only characteristic.
    firmwareVersionCharacteristic = 0x00000201,
      ## Current firmware version. Read-only characteristic.
      ## See `MyohwFwVersion <#MyohwFwVersion>`_.
    emgData1Characteristic = 0x00000205,
      ## Raw EMG data. Notify-only characteristic.
    emgData2Characteristic = 0x00000305,
      ## Raw EMG data. Notify-only characteristic.
    commandCharacteristic = 0x00000401,
      ## Issue commands to the Myo. Write-only characteristic. See MyohwCommand.
    imuDataCharacteristic = 0x00000402,
      ## See MyohwImuData. Notify-only characteristic.
    emgData3Characteristic = 0x00000405,
      ## Raw EMG data. Notify-only characteristic.
    motionEventCharacteristic = 0x00000A02
      ## Motion event data. Indicate-only characteristic.

  MyohwStandardServices* {.pure, size: sizeof(cint).} = enum
    ## Standard Bluetooth device services.
    batteryService = 0x0000180F,
      ## Battery service
    deviceName = 0x00002A00,
      ## Device name data. Read/write characteristic.
    batteryLevelCharacteristic = 0x00002A19
      ## Current battery level information. Read/notify characteristic.

  MyohwPose* {.pure, size: sizeof(cushort).} = enum
    ## Supported poses.
    rest = 0x00000000,
    fist = 0x00000001,
    waveIn = 0x00000002,
    waveOut = 0x00000003,
    fingersSpread = 0x00000004,
    doubleTap = 0x00000005,
    unknown = 0x0000FFFF

type
  MyohwClassifierModelType* {.pure, size: sizeof(cuchar).} = enum
    ## Classifier model types.
    builtin = 0, ## Model built into the classifier package.
    custom = 1

  MyohwSku* {.pure, size: sizeof(cuchar).} = enum
    ## Known Myo SKUs
    unknown = 0, ## Unknown SKU (default value for old firmwares)
    blackMyo = 1, ## Black Myo
    whiteMyo = 2

type
  MyohwFwInfo* = object
    ## Various parameters that may affect the behaviour of this Myo armband.
    ## The Myo library reads this attribute when a connection is established.
    ## Value layout for the myohw_att_handle_fw_info attribute.
    serialNumber*: array[6, cuchar] ## Unique serial number of this Myo.
    unlockPose*: MyohwPose ## Pose that should be interpreted as the unlock pose.
    activeClassifierType*: MyohwClassifierModelType ## Whether Myo is currently
      ## using a built-in or a custom classifier.
    activeClassifierIndex*: cuchar ## Index of the classifier that is currently
      ## active.
    hasCustomClassifier*: cuchar ## Whether Myo contains a valid custom
      ## classifier. 1 if it does, otherwise 0.
    streamIndicating*: cuchar ## Set if the Myo uses BLE indicates to stream
      ## data, for reliable capture.
    sku*: MyohwSku ## SKU value of the device.
    reserved*: array[7, cuchar] ## Reserved for future use; populated with zeros.

type
  MyohwHardwareRev* {.pure, size: sizeof(cushort).} = enum
    ## Known Myo hardware revisions.
    unknown = 0, ## Unknown hardware revision.
    revc = 1, ## Myo Alpha (REV-C) hardware.
    revd = 2, ## Myo (REV-D) hardware.
    revs ## Number of hardware revisions known; not a valid hardware revision.

type
  MyohwFwVersion* = object
    ## Version information for the Myo firmware.
    ##
    ## Minor version is incremented for changes in this interface. Patch version
    ## is incremented for firmware changes that do not introduce changes in this
    ## interface.
    major*: cushort
    minor*: cushort
    patch*: cushort
    hardwareRev*: MyohwHardwareRev
      ## Myo hardware revision.

const
  myohwFirmwareVersionMajor* = 1 ## Firmware's major version number.
  myohwFirmwareVersionMinor* = 2 ## Firmware's minor version number.


type
  MyohwCommand* {.pure, size: sizeof(cuchar).} = enum
    ## Kinds of commands.
    setMode = 0x00000001,
      ## Set EMG and IMU modes.
      ## See `MyohwCommandSetMode <#MyohwCommandSetMode>`_.
    setModeCustom = 0x00000002,
      ## Set EMG and IMU modes with custom parameters.
      ## See `MyohwCommandSetModeCustom <#MyohwCommandSetModeCustom>`_.
    vibrate = 0x00000003,
      ## Vibrate.
      ## See `MyohwCommandVibrate <#MyohwCommandVibrate>`_.
    deepSleep = 0x00000004,
      ## Put Myo into deep sleep.
      ## See `MyohwCommandDeepSleep <#MyohwCommandDeepSleep>`_.
    vibrate2 = 0x00000007,
      ## Extended vibrate.
      ## See `MyohwCommandVibrate2 <#MyohwCommandVibrate2>`_.
    setSleepMode = 0x00000009,
      ## Set sleep mode.
      ## See `MyohwCommandSetSleepMode <#MyohwCommandSetSleepMode>`_.
    unlock = 0x0000000A,
      ## Unlock Myo.
      ## See `MyohwCommandUnlock <#MyohwCommandUnlock>`_.
    userAction = 0x0000000B
      ## Notify user that an action has been recognized /
      ## confirmed. See `MyohwCommandUserAction <#MyohwCommandUserAction>`_.

type
  MyohwCommandHeader* = object
    ## Header that every command begins with.
    command*: MyohwCommand
      ## Command to send.
    payloadSize*: cuchar
      ## Number of bytes in payload.

type
  MyohwEmgMode* {.pure, size: sizeof(cuchar).} = enum
    ## EMG modes.
    none = 0x00000000, ## Do not send EMG data.
    sendEmg = 0x00000002, ## Send filtered EMG data.
    sendEmgRaw = 0x00000003 ## Send raw (unfiltered) EMG data.

  MyohwImuMode* {.pure, size: sizeof(cuchar).} = enum
    ## IMU modes.
    none = 0x00000000,
      ## Do not send IMU data or events.
    sendData = 0x00000001,
      ## Send IMU data streams (accelerometer, gyroscope, and orientation).
    sendEvents = 0x00000002,
      ## Send motion events detected by the IMU
      ## (e.g. taps).
    sendAll = 0x00000003,
      ## Send both IMU data streams and motion events.
    sendRaw = 0x00000004
      ## Send raw IMU data streams.

  MyohwClassifierMode* {.pure, size: sizeof(cuchar).} = enum
    ## Classifier modes.
    disabled = 0x00000000,
      ## Disable and reset the internal state of the onboard classifier.
    enabled = 0x00000001
      ## Send classifier events (poses and arm events).

type
  MyohwCommandSetMode* = object
    ## Command to set EMG and IMU modes.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.setMode <#MyohwCommand>`_, `payloadSize` = 3.
    emgMode*: MyohwEmgMode
      ## EMG sensor mode.
    imuMode*: MyohwImuMode
      ## IMU mode.
    classifierMode*: MyohwClassifierMode
      ## Classifier mode.

type
  MyohwVibrationType* {.pure, size: sizeof(cuchar).} = enum
    ## Kinds of vibrations.
    none = 0x00000000,
      ## Do not vibrate.
    short = 0x00000001,
      ## Vibrate for a short amount of time.
    medium = 0x00000002,
      ## Vibrate for a medium amount of time.
    long = 0x00000003
      ## Vibrate for a long amount of time.

type
  MyohwCommandVibrate* = object
    ## Vibration command.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.vibrate <#MyohwCommand>`_, payload_size = 1.
    vibrationType*: MyohwVibrationType
      ## Vibration type.

  MyohwCommandDeepSleep* = object
    ## Deep sleep command.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.deepSleep <#MyohwCommand>`_, payload_size = 0.

const
  myohwCommandVibrate2Steps* = 6

type
  MyohwCommandVibrate2Steps* = object
    duration*: cushort
      ## Duration (in ms) of the vibration
    strength*: cuchar
      ## Strength of vibration (0 - motor off, 255 - full speed)

  MyohwCommandVibrate2* = object
    ## Extended vibration command.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.vibrate2 <#MyohwCommand>`_, payload_size = 18.
    steps*: array[myohwCommandVibrate2Steps, MyohwCommandVibrate2Steps]

type
  MyohwSleepMode* {.pure, size: sizeof(cuchar).} = enum
    ## Sleep modes.
    normal = 0,
      ## Normal sleep mode. Myo will sleep after a period of inactivity.
    neverSleep = 1
      ## Never go to sleep.

type
  MyohwCommandSetSleepMode* = object
    ## Set sleep mode command.
    header*: MyohwCommandHeader ## `command` =
      ## `MyohwCommand.setSleepMode <#MyohwCommand>`_, payload_size = 1.
    sleepMode*: MyohwSleepMode
      ## Sleep mode.

type
  MyohwUnlockType* {.pure, size: sizeof(cuchar).} = enum
    ## Unlock types.
    lock = 0x00000000,
      ## Re-lock immediately.
    unlockTimed = 0x00000001,
      ## Unlock now and re-lock after a fixed timeout.
    unlockHold = 0x00000002
      ## Unlock now and remain unlocked until a lock command is received.

type
  MyohwCommandUnlock* = object
    ## Unlock Myo command.
    ##
    ## Can also be used to force Myo to re-lock.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.unlock <#MyohwCommand>`_, payload_size = 1.
    unlockType*: MyohwUnlockType
      ## Unlock type.


type
  MyohwUserActionType* {.pure, size: sizeof(cuchar).} = enum
    ## User action types.
    single = 0
      ## User did a single, discrete action, such as pausing a video.

type
  MyohwCommandUserAction* = object
    ## User action command.
    header*: MyohwCommandHeader
      ## `command` = `MyohwCommand.userAction <#MyohwCommand>`_, payload_size = 1.
    actionType*: MyohwUserActionType
      ## Type of user action that occurred.

type
  MyohwImuDataOrientation* = object
    ## Orientation data, represented as a unit quaternion.
    ##
    ## Values are multiplied by `myohwOrientationScale <#myohwOrientationScale>`_.
    w*: cshort
    x*: cshort
    y*: cshort
    z*: cshort

  MyohwImuData* = object
    ## Integrated motion data.
    orientation*: MyohwImuDataOrientation
      ## Orientation data, represented as a unit quaternion. Values are
      ## multiplied by myohwOrientationScale.
    accelerometer*: array[3, cshort]
      ## Accelerometer data. In units of g. Range of + -16. Values are
      ## multiplied by `myohwAccelerometerScale <#myohwAccelerometerScale>`_.
    gyroscope*: array[3, cshort]
      ## Gyroscope data. In units of deg/s. Range of + -2000. Values are
      ## multiplied by `myohwGyroscopeScale <#myohwGyroscopeScale>`_.

const
  myohwDefaultImuSampleRate* = 50 ## Default IMU sample rate in Hz.

const # Scale values for unpacking IMU data
  myohwOrientationScale* = 16384.0
    ## See `MyohwImuData.orientation <#MyohwImuData>`_.
  myohwAccelerometerScale* = 2048.0
    ## See `MyohwImuData.accelerometer <#MyohwImuData>`_.
  myohwGyroscopeScale* = 16.0
    ## See ## See `MyohwImuData.gyroscope <#MyohwImuData>`_.

type
  MyohwMotionEventType* {.pure, size: sizeof(cuchar).} = enum
    ## Types of motion events.
    tap = 0x00000000

type
  MyohwMotionEventData* = object
    ## Motion event data.
    tapDirection*: cuchar
    tapCount*: cuchar


  MyohwMotionEvent* = object
    ## Motion event.
    eventType*: MyohwMotionEventType
      ## Type typeof motion event that occurred.
    data*: MyohwMotionEventData
      ## Event-specific data.

type
  MyohwClassifierEventType* {.pure, size: sizeof(cuchar).} = enum
    ## Types of classifier events.
    armSynced = 0x00000001,
    armUnsynced = 0x00000002,
    pose = 0x00000003,
    unlocked = 0x00000004,
    locked = 0x00000005,
    syncFailed = 0x00000006

type
  MyohwArm* {.pure, size: sizeof(cuchar).} = enum
    ## Enumeration identifying a right arm or left arm.
    right = 0x00000001,
    left = 0x00000002,
    unknown = 0x000000FF


  MyohwXDirection* {.pure, size: sizeof(cuchar).} = enum
    ## Possible directions for Myo's +x axis relative to a user's arm.
    towardWrist = 0x00000001,
    towardElbow = 0x00000002,
    unknown = 0x000000FF


  MyohwSyncResult* {.pure, size: sizeof(cuchar).} = enum
    ## Possible outcomes when the user attempts a sync gesture.
    failedTooHard = 0x00000001 ## Sync gesture was performed too hard.

type
  MyohwClassifierEventArmData* = object
    ## Classifier event data for arm events.
    arm*: MyohwArm
      ## The arm that generated the event data.
    xDirection*: MyohwXDirection
      ## X-direction relative to user's arm.

  MyohwClassifierEventData* = object {.union.}
    armData*: MyohwClassifierEventArmData ## For
      ## `MyohwClassifierEventType.armSynced <#MyohwClassifierEventType>`_
      ## events.
    pose*: MyohwPose ## For
      ## `MyohwClassifierEventType.pose <#MyohwClassifierEventType>`_
      ## events.
    syncResult*: MyohwSyncResult ## For
      ## `MyohwClassifierEventType.syncFailed <#MyohwClassifierEventType>`_
      ## events.


  MyohwClassifierEvent* = object
    ## Classifier event.
    eventType*: MyohwClassifierEventType
      ## Classifier even type.
    data*: MyohwClassifierEventData
      ## Event-specific data.

const
  myohwEmgDefaultStreamingRate* = 200
    ## The rate that EMG events are streamed over Bluetooth.

type
  MyohwEmgData* = object
    ## Raw EMG data.
    sample1*: array[8, cchar] ## 1st sample of EMG data.
    sample2*: array[8, cchar] ## 2nd sample of EMG data.
