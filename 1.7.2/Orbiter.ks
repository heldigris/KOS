lock throttle to 1.
print "blast off!".

function Main{
	doCountdown().
	mySteering().
	doSafeStage().
	until apoapsis > 72000 {
		getInfo().
		mySteering().
		
	}
	doOrbitalInsertion().
	doDeorbit().
	print "Main is over".
}

function doSafeStage{
	wait until stage:ready.
	stage.

}

function doCountdown{
	//This is our countdown loop, which cycles from 3 to 0
	PRINT "Counting down:".
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
	CLEARSCREEN.
}
}

function getInfo {

//print "Heading: " + ship:heading at (0,3).
print "Apoapsis: " + ship:apoapsis at (0,4).
print "Periapsis: " + ship:periapsis at (0,5).
print "Facing: " + ship:facing at (0,6).
print "Velocity: " + ship:velocity:surface:mag at (0,7).
print "ETA Apoapsis: " + ETA:apoapsis at (0,8).
print "ETA Periapsis: " + ETA:periapsis at (0,9).
print "rotasjon: " + (100-((ship:velocity:surface:mag)/10)) at (0,10).

wait 0.


}
function mySteering{
//declare parameter rotasjon.
set rotasjon to (100-((ship:velocity:surface:mag)/10)).
//if 90-((ship:velocity:surface:mag)/10) < 0 {set rotasjon to (90-(ship:velocity:surface:mag/10)).}else{set rotasjon to 90.}
//print "Velocity: " + ship:velocity:surface:mag.
//print (100-((ship:velocity:surface:mag)/12)).
//print rotasjon.
if rotasjon > 90{lock steering to heading(90,90).}
else if rotasjon > 25{
lock steering to heading(90,rotasjon).}
else{lock steering to prograde.}
}

function doOrbitalInsertion {

print "MECO".
until ETA:apoapsis < 12 {
getInfo().
lock throttle to 0.
set steeringmanager:maxstoppingtime to 1.
lock steering to heading(90,0).
}until periapsis > 70000 {
getInfo().
if ETA:apoapsis < 12 {
lock throttle to 1.
lock steering to heading(90,0).}
else if ETA:Apoapsis > 13 and apoapsis < 74000 {lock throttle to 0.5.}
else if apoapsis > 74000{lock throttle to 0.4.
lock steering to heading(90,355).}
}
print "IN SPACE!".
lock throttle to 0.
}

function doDeorbit {
lock steering to retrograde.
wait 10.
until periapsis < 56000{
getInfo().
lock throttle to 0.1.
}
lock throttle to 0.
wait 1.
doSafeStage.
}


Main().
