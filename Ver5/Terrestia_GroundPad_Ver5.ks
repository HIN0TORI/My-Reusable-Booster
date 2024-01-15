//Terrestia Ground Pad Ver5
//Script Ver1

if ship:status = "prelaunch" {
    wait until not core:messages:empty.

    startup().
}
else {
    restart().
}

set ship:name to "Terrestia Booster".

lock throttle to thrott().
lock steering to steer().
set steeringManager:rollts to 50.
//set steeringManager:maxstoppingtime to 1.

rcs on.

until runmode = 0 {
    //Waiting for leaving Secound Stage
    if runmode = 1 {
        wait 3.

        set runmode to 2.
    }
    //BoostBack turn
    else if runmode = 2 {
        if pitchangle() > bbAngle {
            set runmode to 3.
        }
    }
    //BoostBack Burn
    else if runmode = 3 {
        if errordiff(refpoint(0.08, LZ)) < 50 {
            set runmode to 4.

            brakes on.
        }
    }
    //Waiting for Entry
    else if runmode = 4 {
        if ship:verticalSpeed < 0 and landth(ship:maxThrust, 30000, -310) > 1 {
            set runmode to 5.
        }
    }
    //Entry Burn
    else if runmode = 5 {
        if ship:verticalSpeed > -310 {
            set  runmode to 6.
        }
    }
    //Griding
    else if runmode = 6 {
        if rcs and ship:altitude < 20000 {
            rcs off.
        }

        if landth(12857.14, 0, 0) > 1 {
            set runmode to 7.
        }
    }
    //Landing Burn
    else if runmode = 7 {
        //Final Approach
        if landth(3857.142, 0, 0) < 1 {
            enginemode("Center").
        }
        //LandingLeg Deploy
        if not legs and addons:tr:timetillimpact < 3 {
            legs on.
        }
        //Landed
        if ship:status = "landed" or ship:status = "splashed" or ship:verticalspeed > 0 {
            enginemode("AllShutdown").

            unlock all.
            rcs on.
            sas on.

            set runmode to 0.
        }
    }

    wait 0.
}

function thrott {
    if runmode = 1 or runmode = 2 or runmode = 4 or runmode = 6 {
        return 0.
    }
    else if runmode = 3 {
        local error to errordiff(refpoint(0.08, LZ)).

        if error < 10000 {
            return error / 10000.
        }
        else {
            return 1.
        }
    }
    else if runmode = 5 {
        return 1.
    }
    else if runmode = 7 {
        return landth(3857.142, 0, 0).
    }
}

function steer {
    if runmode = 1 {
        return mecosteer.
    }
    else if runmode = 2 {
        if pitchangle() < bbAngle * 0.57 {
            set ship:control:pitch to 1.

            return ship:facing.
        }
        else {
            set ship:control:pitch to 0.

            return heading(- LZ:heading, bbAngle, 0).
        }
    }
    else if runmode = 3 {
        return heading(-LZ:heading, bbAngle, 0) - boostbackpid(refpoint(0.08, LZ)).
    }
    else if runmode = 4 or runmode = 5 {
        if ship:verticalSpeed < 0 and ship:altitude < 70000 {
            return steerpid(-3, 0.1, ship:velocity:surface, errorvector(refpoint(0.3, LZ))).
        }
        else {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
    }
    else if runmode = 6 {
        return steerpid(line(2000, 3, 30000, 7, truealt(), true, 1), 1.2, ship:velocity:surface, errorvector(refpoint(0.2, LZ))).
    }
    else if runmode = 7 {
        if truealt() > 50 {
            return steerpid(-0.5, 0.7, ship:velocity:surface, errorvector(refpoint(0.1, LZ))).
        }
        else {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
    }
}

function startup {
    set runmode to 1.
    set mecosteer to ship:facing.
}

function restart {
    set runmode to 2.
}