
//"completed" functions are (doCountdown, mySteering, circularizationNode, returnPlayerControl)
/Cannot launch in any inclination. Only 0
// the rest are WIP

parameter targetApoaps is 80.

set targetApoaps to targetApoaps * 1000.
set targetPeriaps to 70000.
set targetDeorbitPeriapsis to 35000.



FUNCTION Main{
	CLEARSCREEN.
	LOCK THROTTLE TO 1.
	doCountdown().
	
	UNTIL APOAPSIS > targetApoaps {
		
		getInfo().
		mySteering().
		stageChecker().
		
	}

	LOCK THROTTLE TO 0.
	UNTIL SHIP:ALTITUDE > 70000{
	
	getInfo().
	
	}
	
	circularizationNode().
	returnPlayerControl().
	
}

FUNCTION doSafeStage{

	wait until stage:ready.
	stage.

}

FUNCTION doCountdown{
	//This is our countdown loop, which cycles from 3 to 0
	PRINT "Counting down:".
	FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT "..." + countdown.
		WAIT 1. // pauses the script here for 1 second.
	CLEARSCREEN.
	}
}

FUNCTION getInfo {

	print "Velocity: " + round(ship:velocity:surface:mag,1) at (0,4).
	
	print "Apoapsis: " + round(ship:apoapsis,1) at (0,6).
	print "Periapsis: " + round(ship:periapsis,1) at (0,7).

	print "ETA Apoapsis: " + round(ETA:apoapsis,1) at (0,9).
	print "ETA Periapsis: " + round(ETA:periapsis,1) at (0,10).	


//	print "rotasjon: " + round((100-((ship:velocity:surface:mag)/10)),1) at (0,12).
//	print "VANG: " + round(vAng(Prograde:vector,ship:facing:vector),1) at (0,14).
//	print "Facing: " + ship:facing at (0,26).
//	print "Prograde: " + prograde at (0,27).
//	print "Heading: " + round(ship:heading,1) at (0,28).
	wait 0.


}

FUNCTION mySteering{

	PRINT "**                                              **" at (0,1).
	PRINT "**                Ascending                     **" at (0,2).
	PRINT "**                                              **" at (0,3).
	
	set rotasjon to (100-((ship:velocity:surface:mag)/10)).
		
		if rotasjon > 90{
		
			lock steering to heading(0,90).
			
		}
		
		else if rotasjon > 5{
			
			lock steering to heading(45,rotasjon).
			
		}

		else{
	
			lock steering to heading(90,5).
			
		}

}

//Working on deprecation
FUNCTION doOrbitalInsertion {

	PRINT "**                                              **" at (0,1).
	PRINT "**                MECO                          **" at (0,2).
	PRINT "**                                              **" at (0,3).
	
	
	
	until ETA:apoapsis < 13 {
		getInfo().
		lock throttle to 0.
		set steeringmanager:maxstoppingtime to 1.
		lock steering to heading(90,0).
		
	}

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
	getInfo().
}

FUNCTION doDeorbit {

	PRINT "**                Deorbiting                    **" (0,1).
	PRINT "**           Target periapsis 35k               **" (0,2).
	PRINT "**         Holding retrograde to 15k            **" (0,3).

	lock steering to retrograde.
	wait 10.
	until periapsis < 35000{
	getInfo().
	lock throttle to 0.1.
	}
	lock throttle to 0.
	wait 1.
	doSafeStage.
	
	until SHIP:ALTITUDE < targetDeorbitPeriapsis{
	
		lock steering to srfretrograde.
		PRINT "Trying to hold retrograde until 15k" AT (0,20).
		WAIT 0.
	}
}

FUNCTION stageChecker {
	if STAGE:NUMBER > 0{
			wait 0.
			set ignitionlistfalse to list().
			set ignitionlisttrue to list().
			set ignitionflameout to list().
			LIST ENGINES IN elist.
			PRINT "Stage: " + STAGE:NUMBER AT (0,11).
			
			
			
			FOR e IN elist {
				IF e:ignition{
				
					ignitionListtrue:add(e:ignition).
					
					if e:flameout{
						ignitionflameout:add(e:flameout).
					}
					
				}
				else{

					ignitionListfalse:add(e:ignition).

				}
		}
			
		if ignitionflameout:length = ignitionlisttrue:length{

			doSafeStage().
		
		}
	
	}
	
//	print "ignFlamout: " + ignitionflameout:length at (0,31).
//	print "ignTrue: " + ignitionlisttrue:length at (0,32).
//	print "ignFalse: " + ignitionListfalse:length at (0,33).
	
}

FUNCTION circularizationNode{

	SET orbitalSpeed TO sqrt((SHIP:BODY:MU / (SHIP:BODY:RADIUS + 
	SHIP:APOAPSIS))).
	SET T to time:SECONDS+ETA:APOAPSIS.
	SET B to VELOCITYAT(ship, time+eta:apoapsis):orbit.
	SET Dv to orbitalSpeed - B:MAG.

	add node(T,0,0,round(Dv,1)).

}

FUNCTION doManouver{
	CLEARSCREEN.
	set nd to nextnode.
	print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).
	
	set max_acc to tsiolkovskys(max_acc).

	set burn_duration to nd:deltav:mag/max_acc.
	
	print "Crude Estimated burn duration: " + round(burn_duration) + "s".
	
	wait until nd:eta <= (burn_duration/2 + 60).
	
	set np to nd:deltav. //points to node, don't care about the roll direction.
	lock steering to np.

	//now we need to wait until the burn vector and ship's facing are aligned
	wait until vang(np, ship:facing:vector) < 0.25.

	//the ship is facing the right direction, let's wait for our burn time
	wait until nd:eta <= (burn_duration/2).

	//we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
	set tset to 0.
	lock throttle to tset.

	set done to False.
	//initial deltav
	set dv0 to nd:deltav.
	until done{
		//recalculate current max_acceleration, as it changes while we burn through fuel
		set max_acc to tsiolkovskys(max_acc).

		//throttle is 100% until there is less than 1 second of time left to burn
		//when there is less than 1 second - decrease the throttle linearly
		set tset to min(nd:deltav:mag/max_acc, 1).

		//here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
		//this check is done via checking the dot product of those 2 vectors
		if vdot(dv0, nd:deltav) < 0
		{
			print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			lock throttle to 0.
			break.
		}

		//we have very little left to burn, less then 0.1m/s
		if nd:deltav:mag < 0.1
		{
			print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			//we burn slowly until our node vector starts to drift significantly from initial vector
			//this usually means we are on point
			wait until vdot(dv0, nd:deltav) < 0.5.

			lock throttle to 0.
			print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			set done to True.
		}
	}
	unlock steering.
	unlock throttle.
	wait 1.

	//we no longer need the maneuver node
	remove nd.

	//set throttle to 0 just in case.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

}

// WIP
FUNCTION tsiolkovskys {

	//tsiolkovskys equation = max_acc
	set ispValue to 0.
	LIST ENGINES IN elist.
	
	
	FOR e IN elist {
		IF e:ignition{
			set engineThrust to e:possiblethrust/(e:possiblethrust/e:isp).
			set ispValue to ispValue + engineThrust.
			print e:isp.
			
		}
	}

	set max_acc to ispValue*constant:g0*ln(ship:wetmass/ship:drymass).

	return max_acc.

}

FUNCTION returnPlayerControl {

	CLEARSCREEN.

	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**                                              **".
	PRINT "**      Transferring control back to            **".
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
