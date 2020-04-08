lock throttle to 1.
print "blast off!".

set targetApoaps to 75000.
set targetPeriaps to 70000.

function Main{

	doCountdown().
	mySteering().
	doSafeStage().
	until apoapsis > targetApoaps {
		
		getInfo().
		mySteering().
		
	}
	doOrbitalInsertion().
	doDeorbit().
	returnPlayerControl().
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

	print "Velocity: " + round(ship:velocity:surface:mag,1) at (0,3).
	
	print "Apoapsis: " + round(ship:apoapsis,1) at (0,5).
	print "Periapsis: " + round(ship:periapsis,1) at (0,6).

	print "ETA Apoapsis: " + round(ETA:apoapsis,1) at (0,8).
	print "ETA Periapsis: " + round(ETA:periapsis,1) at (0,9).	


//	print "rotasjon: " + round((100-((ship:velocity:surface:mag)/10)),1) at (0,12).
//	print "VANG: " + round(vAng(Prograde:vector,ship:facing:vector),1) at (0,14).
//	print "Facing: " + ship:facing at (0,16).
//	print "Heading: " + round(ship:heading,1) at (0,3).
	wait 0.


}
function mySteering{

	set rotasjon to (100-((ship:velocity:surface:mag)/10)).
		
		if rotasjon > 90{
		
			lock steering to heading(0,90).
			stageChecker().
		}
		
		else if rotasjon > 10{
			
			lock steering to heading(90,rotasjon).
			stageChecker().
		}

		else if vAng(Prograde:vector,ship:facing:vector) > 1 {
	
			lock steering to heading(90,10).
			stageChecker().
		}

		else if prograde < 5{
			
			lock steering to heading(90,5).
			stageChecker().
		}
	
		else {
		
			lock steering to srfprograde.
			stageChecker().
		
		}

}

function doOrbitalInsertion {

	PRINT "**                                              **".
	PRINT "**                MECO                          **".
	PRINT "**                                              **".
	
	
	
	until ETA:apoapsis < 13 {
		getInfo().
		lock throttle to 0.
		set steeringmanager:maxstoppingtime to 1.
		lock steering to heading(90,0).
//		dophysicsWarpStart().
		
	}
	
//	dophysicsWarpStop().
	
	until periapsis > targetPeriaps {
		stageChecker().
		getInfo().
		
		if ETA:apoapsis < 12 {
		
			lock throttle to 1.
			lock steering to heading(90,0).
			
			if ETA:apoapsis < 5{
			
				lock throttle to 1.
				lock steering to heading(90,10).
				
			}
		}
			else if ETA:Apoapsis > ETA:Periapsis{
			
				lock throttle to 1.
				lock steering to heading(90,40).
			
			}
			else if ETA:Apoapsis > 13 and apoapsis < targetApoaps {

				until ETA:Apoapsis < 6 {
					
					getInfo().
					lock throttle to 0.
				
				}
				
			}		
	}
	
	lock throttle to 0.
}

function doDeorbit {

	lock steering to retrograde.
	wait 10.
	until periapsis < 35000{
	getInfo().
	lock throttle to 0.1.
	}
	lock throttle to 0.
	wait 1.
	doSafeStage.
}

function stageChecker {
	if STAGE:NUMBER > 0{
		LIST ENGINES IN elist.
			PRINT "Stage: " + STAGE:NUMBER AT (0,0).
			
			FOR e IN elist {
				IF e:FLAMEOUT {
				
					doSafeStage().

					LIST ENGINES IN elist.
					CLEARSCREEN.
					BREAK.
				}
			}
	}

}

//FUNGERER IKKE
function dophysicsWarpStart{
set warpState to kuniverse:timewarp:mode.
set warpRateState to kuniverse:timewarp:warp.

	if kuniverse:timewarp:mode = "PHYSICS" and kuniverse:timewarp:warp = 0{
		
		
		print warpState at (0,20).
		set kuniverse:timewarp:warp to 2.
		wait 0.1.
	
	}
	else if kuniverse:timewarp:mode = "RAILS"{
	
		set kuniverse:timewarp:warp to 0.
		
	
	}
	

}
//FUNGERE IKKE
function dophysicsWarpStop {

set kuniverse:timewarp:warp to 0.

}

Function returnPlayerControl {

	CLEARSCREEN.

	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**       Transferring control back  to  you     **".
	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**                      _                       **".
	PRINT "**                     / \                      **".
	PRINT "**                    |.-.|                     **".
	PRINT "**                    |   |                     **".
	PRINT "**                    | H |                     **".
	PRINT "**                    | E |                     **".
	PRINT "**                    | L |                     **".
	PRINT "**                  _ | D | _                   **".
	PRINT "**                 / \| I |/ \                  **".
	PRINT "**                |   | G |   |                 **".
	PRINT "**                |   | R |   |                 **".
	PRINT "**               ,'   | I |   '.                **".
	PRINT "**             ,' |   | S |   | `.              **".
	PRINT "**           .'___|___|_ _|___|___'.            **".
	PRINT "**                 /_\ /_\ /_\                  **".
	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**                                              **".

}

Main().
