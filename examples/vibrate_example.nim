## *myo* - Nim bindings for the Thalmic Labs Myo gesture control armband SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libmyo, os


# The following program is a basic example of using `libmyo` to connect to a
# Myo armband and vibrate it.

const appId: cstring = "us.nimio.examples.vibrate"

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


# initialize hub
if libmyoInitHub(addr hub, appId, addr errorDetails) != LibmyoResult.success:
  echo "Error: Failed to initialize hub"
else:
  while myo == nil:
    echo "Attempting to find a Myo..."
    if libmyoRun(hub, 1000, findMyoHandler, nil, addr errorDetails) != LibmyoResult.success:
      echo "Error: Failed to find devices"
      break

  # vibrate it
  if myo != nil:
    echo "Found a Myo"
    echo "Vibrating short..."
    if libmyoVibrate(myo, LibmyoVibrationType.short, addr errorDetails) != LibmyoResult.success:
      echo "Warning: Failed to vibrate Myo (short)"
    sleep(1000)
    echo "Vibrating medium..."
    if libmyoVibrate(myo, LibmyoVibrationType.medium, addr errorDetails) != LibmyoResult.success:
      echo "Warning: Failed to vibrate Myo (medium)"
    sleep(1000)
    echo "Vibrating long..."
    if libmyoVibrate(myo, LibmyoVibrationType.long, addr errorDetails) != LibmyoResult.success:
      echo "Warning: Failed to vibrate Myo (long)"

  # shut down hub
  if libmyoShutdownHub(hub, addr errorDetails) != LibmyoResult.success:
    echo "Warning: Failed to shut down hub"
