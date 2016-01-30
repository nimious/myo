## *myo* - Nim bindings for the Thalmic Labs Myo gesture control armband SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

{.deadCodeElim: on.}


when defined(macosx):
  const dllname = "/Library/Frameworks/myo.framework/myo"
elif defined(windows):
  when defined(amd64):
    const dllname = "myo64.dll"
  else:
    const dllname = "myo32.dll"
else:
  {.error: "myo does not support this platform".}


type
  LibmyoHub* = pointer
    ## Handle to the Myo hub.
    ##
    ## The hub provides access to one or more Myo armbands. On Windows and
    ## MacOS, the hub is typically the Myo Connect application that also takes
    ## are of things like pairing and global user preferences.


  LibmyoResult* {.pure, size: sizeof(cint).} = enum
    ## Possible return values for all libmyo procs that may fail.
    success,
      ## The proc was successful
    error,
      ## An error occured (use `libmyoErrorXXX` to get error details)
    errorInvalidArgument,
      ## An argument was invalid
    errorRuntime
      ## Runtime error occured


  LibmyoErrorDetails* = pointer
    ## Opaque handle to detailed error information.


proc libmyoErrorCstring*(details: LibmyoErrorDetails): cstring
  {.cdecl, dynlib: dllname, importc: "libmyo_error_cstring".}
  ## Get a detailed error message for a given error.
  ##
  ## details
  ##   Handle to the error details to get the message for
  ## result
  ##   A nil-terminated string containing the error message


proc libmyoErrorKind*(details: LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_error_kind".}
  ## Get the kind of error that occurred.
  ##
  ## details
  ##   Handle to the error details to get the error kind for
  ## result
  ##   The kind of error that occured


proc libmyoFreeErrorDetails*(details: LibmyoErrorDetails)
  {.cdecl, dynlib: dllname, importc: "libmyo_free_error_details".}
  ## Free the object associated with an error details handle.
  ##
  ## details
  ##   Handle to the error details to free


proc libmyoInitHub*(outHub: ptr LibmyoHub; appId: cstring;
  outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_init_hub".}
  ## Initialize a connection to the hub.
  ##
  ## outHub
  ##   Will contain the handle to the initialized hub
  ## appId
  ##   Application identifier
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the connection was established
  ##   - `errorRuntime <#LibmyoResult>`_ if connection could not be established
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `outHub` is `nil`
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `appId` is longer than 255
  ##     characters
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `appId` is not in the proper
  ##     reverse domain name format (see below)
  ##
  ## `appId` must follow a reverse domain name format (com.domainname.appname).
  ## Application identifiers can be formed from the set of alphanumeric ASCII
  ## characters (a-z, A-Z, 0-9). The hyphen (-) and underscore (_) characters
  ## are permitted if they are not adjacent to a period (.) character (i.e. not
  ## at the start or end of each segment), but are not permitted in the
  ## top-level domain. Application identifiers must have three or more segments.
  ##
  ## For example, if a company's domain is example.com and the application is
  ## named hello-world, one could use "com.example.hello-world" as a valid
  ## application identifier. `appId` can be `nil` or empty.


proc libmyoShutdownHub*(hub: LibmyoHub; outError: ptr LibmyoErrorDetails):
  LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_shutdown_hub".}
  ## Free resources allocated to a hub.
  ##
  ## hub
  ##   The hub to free
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if shutdown is successful
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `hub` is `nil`
  ##   - `error <#LibmyoResult>`_ if `hub` is not a valid hub


type
  LibmyoLockingPolicy* {.pure, size: sizeof(cint).} = enum
    ## Supported locking policies.
    none,
      ## Pose events are always sent
    standard
      ## Pose events are not sent while a Myo is locked


proc libmyoSetLockingPolicy*(hub: LibmyoHub; policy: LibmyoLockingPolicy;
  outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_set_locking_policy".}
  ## Set the locking policy for Myos connected to the hub.
  ##
  ## hub
  ##   The hub to set the locking policy for
  ## policy
  ##   The locking policy
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the locking policy is successfully set
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `hub` is `nil`
  ##   - `error <#LibmyoResult>`_ if `hub` is not a valid hub


type
  LibmyoMyo* = pointer
    ## Opaque type corresponding to a known Myo device.

  LibmyoVibrationType* {.pure, size: sizeof(cint).} = enum
    ## Types of vibration.
    short,
    medium,
    long


proc libmyoVibrate*(myo: LibmyoMyo; vibrationType: LibmyoVibrationType;
  outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_vibrate".}
  ## Vibrate the given myo.
  ##
  ## myo
  ##   The Myo armband to vibrate
  ## vibrationType
  ##   The type of vibration to play
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the Myo successfully vibrated
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`


proc libmyoRequestRssi*(myo: LibmyoMyo; outError: ptr LibmyoErrorDetails):
  LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_request_rssi".}
  ## Request the RSSI for a given myo.
  ##
  ## myo
  ##   The Myo armband to request the RSSI for
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the Myo successfully got the RSSI
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`


type
  LibmyoStreamEmg* {.pure, size: sizeof(cint).} = enum
    ## EMG streaming modes.
    disabled,
      ## Do not send EMG data
    enabled
      ## Send EMG data


proc libmyoSetStreamEmg*(myo: LibmyoMyo; emg: LibmyoStreamEmg;
  outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_set_stream_emg".}
  ## Set whether or not to stream EMG data for a given myo.
  ##
  ## myo
  ##   The Myo armband to set streaming for
  ## emg
  ##   The streaming mode
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the EMG mode was set successfully
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`


type
  LibmyoPose* {.pure, size: sizeof(cint).} = enum
    ## Supported poses.
    rest = 0,
      ## Rest pose
    fist = 1,
      ## User is making a fist
    waveIn = 2,
      ## User has an open palm rotated towards the posterior of their wrist
    waveOut = 3,
      ## User has an open palm rotated towards the anterior of their wrist
    fingersSpread = 4,
      ## User has an open palm with their fingers spread away from each other
    doubleTap = 5,
      ## User tapped their thumb and middle finger together twice in succession
    numPoses,
      ## Number of poses supported; not a valid pose
    unknown = 0x0000FFFF


  LibmyoUnlockType* {.pure, size: sizeof(cint).} = enum
    ## Valid unlock types.
    timed = 0,
      ## Unlock for a fixed period of time
    hold = 1
       ## Unlock until explicitly told to re-lock


proc libmyoMyoUnlock*(myo: LibmyoMyo; unlockType: LibmyoUnlockType;
  outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_myo_unlock".}
  ## Unlock the given Myo.
  ##
  ## myo
  ##   The Myo armband to unlock
  ## unlockType
  ##   The unlock type
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the Myo was successfully unlocked
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`
  ##
  ## Can be called when a Myo is paired.
  ## A `LibmyoEventUnlocked <#LibmyoEventUnlocked>`_ event will be generated if
  ## the Myo was locked.

proc libmyoMyoLock*(myo: LibmyoMyo; outError: ptr LibmyoErrorDetails):
  LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_myo_lock".}
  ## Lock the given Myo immediately.
  ##
  ## myo
  ##   The Myo armband to lock
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the Myo was successfully locked
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`
  ##
  ## Can be called when a Myo is paired.
  ## A `LibmyoEventLocked <#LibmyoEventLocked>`_ event will be generated if the
  ## Myo was unlocked.


type
  LibmyoUserActionType* {.pure, size: sizeof(cint).} = enum
    ## User action types.
    single = 0
      ## User did a single, discrete action, such as pausing a video


proc libmyoMyoNotifyUserAction*(myo: LibmyoMyo;
  actionType: LibmyoUserActionType; outError: ptr LibmyoErrorDetails):
  LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_myo_notify_user_action".}
  ## Notify the given Myo that a user action was recognized.
  ##
  ## myo
  ##   The Myo armband to Notify
  ## outError
  ##   Will contain error details if the operation failed
  ## result
  ##   - `success <#LibmyoResult>`_ if the Myo was successfully notified
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `myo` is `nil`
  ##
  ## Can be called when a Myo is paired. Will cause Myo to vibrate.


type
  LibmyoEventType* {.pure, size: sizeof(cint).} = enum
    ## Types of events.
    paired,
      ## Successfully paired with a Myo
    unpaired,
      ## Successfully unpaired from a Myo
    connected,
      ## A Myo has successfully connected
    disconnected,
      ## A Myo has been disconnected
    armSynced,
      ## A Myo has recognized that the sync gesture has been successfully
      ## performed
    armUnsynced,
      ## A Myo has been moved or removed from the arm
    orientation,
      ## Orientation data has been received
    pose,
      ## A change in pose has been detected (see `Libmyo_Pose <#Libmyo_Pose>`_)
    rssi,
      ## An RSSI value has been received
    unlocked,
      ## A Myo has become unlocked
    locked,
      ## A Myo has become locked
    emg
      ## EMG data has been received

  LibmyoEvent* = pointer
    ## Information about an event.


proc libmyoEventGetType*(event: LibmyoEvent): LibmyoEventType
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_type".}
  ## Retrieve the type of an event.
  ##
  ## event
  ##   The event to return the type for
  ## result
  ##   The event type


proc libmyoEventGetTimestamp*(event: LibmyoEvent): culonglong
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_timestamp".}
  ## Retrieve the timestamp of an event.
  ##
  ## event
  ##   The event to return the timestamp for
  ## result
  ##   The timestamp
  ##
  ## See `libmyoNow <#libmyoNow>`_ for details on timestamps.


proc libmyoEventGetMyo*(event: LibmyoEvent): LibmyoMyo
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_myo".}
  ## Retrieve the Myo associated with an event.
  ##
  ## event
  ##   The event
  ## result
  ##   The Myo armband associated with the event


type
  LibmyoVersionComponent* {.pure, size: sizeof(cint).} = enum
    ## Version number components.
    major,
      ## Major version
    minor,
      ## Minor version
    patch,
      ## Patch version
    hardwareRev
      ## Hardware revision


  LibmyoHardwareRev* {.pure, size: sizeof(cint).} = enum
    ## Hardware revisions.
    revC = 1,
      ## Alpha units
    revD = 2
      ## Consumer units


proc libmyoEventGetFirmwareVersion*(event: LibmyoEvent;
  component: LibmyoVersionComponent): cint
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_firmware_version".}
  ## Retrieve the Myo armband's firmware version from an event.
  ##
  ## event
  ##   The event
  ## component
  ##   The component of the version number to get
  ## result
  ##   The version number component value
  ##
  ## Valid for `LibmyoEventPaired <#LibmyoEventPaired>`_ and
  ## `LibmyoEventConnected <#LibmyoEventConnected>`_ events.


type
  LibmyoArm* {.pure, size: sizeof(cint).} = enum
    ## Enumeration identifying a right arm or left arm
    right,
      ## Myo is on the right arm
    left,
      ## Myo is on the left arm
    unknown
      ## Unknown arm


proc libmyoEventGetArm*(event: LibmyoEvent): LibmyoArm
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_arm".}
  ## Retrieve the arm associated with an event.
  ##
  ## event
  ##   The event
  ## result
  ##   The arm associated with the event
  ##
  ## Valid for `LibmyoEventArmSynced <#LibmyoEventArmSynced>`_ events only.


type
  LibmyoXDirection* {.pure, size: sizeof(cint).} = enum
    ## Possible directions for Myo's +x axis relative to a user's arm.
    towardWrist,
      ## Myo's +x axis is pointing toward the user's wrist
    towardElbow,
      ## Myo's +x axis is pointing toward the user's elbow
    unknown
      ## Unknown +x axis direction


proc libmyoEventGetXDirection*(event: LibmyoEvent): LibmyoXDirection
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_x_direction".}
  ## Retrieve the x-direction associated with an event.
  ##
  ## event
  ##   The event
  ## result
  ##   The x-direction associated with the event
  ##
  ## The x-direction specifies which way Myo's +x axis is pointing relative to
  ## the user's arm. Valid for `LibmyoEventArmSynced <#LibmyoEventArmSynced>`_
  ## events only.


type
  LibmyoOrientationIndex* {.size: sizeof(cint).} = enum
    ## Index into orientation data, which is provided as a quaternion.
    x = 0,
      ## First component of the quaternion's vector part
    y = 1,
      ## Second component of the quaternion's vector part
    z = 2,
      ## Third component of the quaternion's vector part
    w = 3
      ## Scalar component of the quaternion


proc libmyoEventGetOrientation*(event: LibmyoEvent;
  index: LibmyoOrientationIndex): cfloat
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_orientation".}
  ## Retrieve orientation data associated with an event.
  ##
  ## event
  ##   The event
  ## index
  ##   The index of the orientation data to get
  ## result
  ##   The orientation data
  ##
  ## Valid for `LibmyoEventOrientation <#LibmyoEventOrientation>`_ events only.


proc libmyoEventGetAccelerometer*(event: LibmyoEvent; index: cuint): cfloat
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_accelerometer".}
  ## Retrieve raw accelerometer data associated with an event in units of g.
  ##
  ## event
  ##   The event
  ## index
  ##   The index of the accelerometer data to get (0..2)
  ## result
  ##   The accelerometer data
  ##
  ## Valid for `LibmyoEventOrientation <#LibmyoEventOrientation>`_ events only.


proc libmyoEventGetGyroscope*(event: LibmyoEvent; index: cuint): cfloat
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_gyroscope".}
  ## Retrieve raw gyroscope data associated with an event in units of deg/s.
  ##
  ## event
  ##   The event
  ## result
  ##   The gyroscope data associated with the event
  ##
  ## Valid for `LibmyoEventOrientation <#LibmyoEventOrientation`_ events only.


proc libmyoEventGetPose*(event: LibmyoEvent): LibmyoPose
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_pose".}
  ## Retrieve the pose associated with an event.
  ##
  ## event
  ##   The event
  ## result
  ##   The pose assoiated with the event
  ##
  ## Valid for `LibmyoEventPose <#LibmyoEventPose>`_ events only.


proc libmyoEventGetRssi*(event: LibmyoEvent): cschar
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_rssi".}
  ## Retreive the RSSI associated with an event.
  ##
  ## event
  ##   The event
  ## result
  ##   The RSSI associated with the event
  ##
  ## Valid for `LibmyoEventRssi <#LibmyoEventRssi>`_ events only.


proc libmyoEventGetEmg*(event: LibmyoEvent; sensor: cint): cschar
  {.cdecl, dynlib: dllname, importc: "libmyo_event_get_emg".}
  ## Retrieve an EMG data point associated with an event.
  ##
  ## event
  ##   The event
  ## sensor
  ##   The index of the EMG sensor to query (0..7)
  ## result
  ##   The EMG data point
  ##
  ## Valid for `LibmyoEventEmg <#LibmyoEventEmg>`_ events only.


type
  LibmyoHandlerResult* {.pure, size: sizeof(cint).} = enum
    ## Return type for event handlers.
    continueProcessing,
      ## Continue processing events
    stop
      ## Stop processing events


type
  LibmyoHandler* = proc (userData: pointer; event: LibmyoEvent):
    LibmyoHandlerResult
    ## Callback function type to handle events as they occur from
    ## `libmyoRun <#libmyoRun>`_.


proc libmyoRun*(hub: LibmyoHub; duration: cint; handler: LibmyoHandler;
  userData: pointer; outError: ptr LibmyoErrorDetails): LibmyoResult
  {.cdecl, dynlib: dllname, importc: "libmyo_run".}
  ## Process events and call the provided callback as they occur.
  ##
  ## hub
  ##   The hub to process events for
  ## duration
  ##   The maximum duration to process events for (in milliseconds)
  ## handler
  ##   The handler proc
  ## result
  ##   - `success <#LibmyoResult>`_ after a successful run
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `hub` is `nil`
  ##   - `errorInvalidArgument <#LibmyoResult>`_ if `handler` is `nil`
  ##
  ## Runs for up to approximately `duration` milliseconds or until a called
  ## handler returns `LibmyoHandlerResult.stop <#LibmyoHandlerResult>`_.
