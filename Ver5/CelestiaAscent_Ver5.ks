//Cekestia Ascent Ver5
//Script Ver1

if ship:status = "prelaunch" {
    startup().
}
else {
    restart().
}

set ship:name to MissionName.
lock throttle to thrott().
lock steering to steer().
set steeringManager:rollts to 50.
set steeringManager:maxstoppingtime to 1.

until runmode = 0 {
    //Countdown
    if runmode = 1 {
        //Ignition
        if CountdownT = IgnitionT {
            enginemode("full").
        }

        //lift off
        if CountdownT = 0 {
            stage.
            set runmode to 2.
        }
        //wait 1s
        else {
            set CountdownT to CountdownT - 1.
            wait 1.
        }
    }
    //MECO
    else if runmode = 2 {
        if (location_T = "GroundPad" and fuelamount("TerrestiaTank", "liquidfuel") < mecofuel) or (location_T = "ASDS" and lngerrordiff(refpoint(0.1, LZ_T)) < 1500) or (location_T = "Expendable" and fuelamount("TerrestiaTank", "liquidfuel") = 0) {
            set meco to true.

            wait 1.

            TerrestiaCPU:connection:sendmessage("SSS").
            stage.
            rcs on.
            set ship:control:fore to 1.

            wait 5.

            set ship:control:fore to 0.

            set runmode to 3.
        }
    }
    //SECO
    else if runmode = 3 {
        if ship:apoapsis > POrbit {
            set runmode to 4.
        }
    }
    //Maneuver Node
    else if runmode = 4 {
        //create node
        if not hasNode {
            if ship:altitude > 70000 {
                wait 0.
                createnode().
                set dv0 to tgnode:deltav.
            }
        }
        //execute node
        else {
            if tgnode:eta < burntime + 60 and warp <> 0 {
                set warp to 0.
            }
            if vdot(dv0, tgnode:deltav) < 0 or tgnode:deltav:mag < 0.1 {
                remove tgnode.

                unlock all.
                set runmode to 0.
            }
        }
    }

    //fairing separation
    if not fairingjet and ship:altitude > fairingalt {
        fairing().
    }

    wait 0.
}

reboot.

function thrott {
    if runmode = 1 {
        return 1.
    }
    else if runmode = 2 {
        if meco {
            return 0.
        }
        else {
            return 1.
        }
    }
    else if runmode = 3 {
        return 1.
    }
    else if runmode = 4 {
        if hasNode and tgnode:eta < burntime {
            return min(tgnode:deltav:mag / (acc(ship:maxthrust) / 5), 1).
        }
        else {
            return 0.
        }
    }
}

function steer {
    if runmode = 1 {
        return ship:up.
    }
    else if runmode = 2 or runmode = 3 {
        if ship:altitude > 250 {
            if pitchangle() > GTAngle {
                return gravityturn().
            }
            else {
                return heading(90, GTAngle, 0).
            }
        }
        else {
            return ship:up.
        }
    }
    else if runmode = 4 {
        if hasNode {
            if tgnode:deltav:mag < 5 {
                return ship:facing.
            }
            else {
                return lookDirUp(tgnode:deltav, facing:topvector).
            }
        }
        else {
            return lookDirUp(ship:prograde:vector, facing:topvector).
        }
    }
}

function startup {
    set runmode to 1.

    set meco to false.
    set fairingjet to false.
    set TerrestiaCPU to processor("Terrestia").
    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if defined LZ_T = false {
        set location_T to "Expendable".
    }
    else {
        for LZ_Ground in LZlist[0] {
            if LZ_Ground = LZ_T {
                set location_T to "GroundPad".
                set mecofuel to fuelamount("TerrestiaTank", "liquidfuel") * 0.3.
                break.
            }
            else {
                for LZ_ASDS in LZlist[1] {
                    if LZ_ASDS = LZ_T {
                        set location_T to "ASDS".
                        break.
                    }
                }
            }
        }
    }
}

function restart {
    set runmode to 3.

    if ship:altitude > FairingAlt {
        set fairingjet to true.
    }
    else {
        set fairingjet to false.
    }

    rcs on.
}