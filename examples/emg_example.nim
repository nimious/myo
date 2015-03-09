## *io-myo* - Nim bindings for the Thalmic Labs Myo gesture control armband SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libmyo


# The following program is a basic example of using `libmyo` to connect to a
# Myo armband and log out EMG data.

const appId: cstring = "us.nimio.examples.emg"

var errorDetails: LibmyoErrorDetails
var hub: LibmyoHub
var myo: LibmyoMyo


proc findMyoHandler(userData: pointer; event: LibmyoEvent): LibmyoHandlerResult =
  myo = libmyoEventGetMyo(event)
  case libmyoEventGetType(event)
  of LibmyoEventType.paired:
    return LibmyoHandlerResult.stop
  else:
    return LibmyoHandlerResult.continueProcessing


proc runHandler(userData: pointer; event: LibmyoEvent): LibmyoHandlerResult =
  echo "event"
  let m = libmyoEventGetMyo(event)
  if m != nil:
    case libmyoEventGetType(event)
    of LibmyoEventType.armSynced:
      echo "Arm synced"
    of LibmyoEventType.armUnsynced:
      echo "Arm unsynced"
    of LibmyoEventType.connected:
      echo "Connected"
    of LibmyoEventType.disconnected:
      echo "Disconnected"
    of LibmyoEventType.emg:
      echo "EMG data"
    of LibmyoEventType.locked:
      echo "Locked"
    of LibmyoEventType.paired:
      echo "Discovered a Myo"
    of LibmyoEventType.unlocked:
      echo "Unlocked"
    of LibmyoEventType.unpaired:
      echo "Unpaired"
    else:
      echo "Unsupported event type"
  LibmyoHandlerResult.continueProcessing  


# initialize hub
if libmyoInitHub(addr hub, appId, addr errorDetails) != LibmyoResult.success:
  echo "Error: Failed to initialize hub"
else:
  echo "Attempting to find a Myo..."
  while myo == nil:
    if libmyoRun(hub, 1000, findMyoHandler, nil, addr errorDetails) != LibmyoResult.success:
      echo "Error: Failed to find devices"
      break

  # enable EMG stream
  if myo != nil:
    if libmyoSetStreamEmg(myo, LibmyoStreamEmg.enabled, addr errorDetails) != LibmyoResult.success:
      echo "Error: Failed to enable EMG stream"
    else:
      while true:
        if libmyoRun(hub, 50, runHandler, nil, addr errorDetails) != LibmyoResult.success:
          echo "Error: Failed to run main loop"
          break

  # shut down hub
  if libmyoShutdownHub(hub, addr errorDetails) != LibmyoResult.success:
    echo "Warning: Failed to shut down hub"
