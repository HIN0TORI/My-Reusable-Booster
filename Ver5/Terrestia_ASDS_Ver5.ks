//Terrestia ASDS Ver5
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
        brakes on.
    }
    //Waiting for Entry
    else if runmode = 2 {
        if ship:verticalSpeed < 0 and landth(ship:maxThrust, 35000, -350) > 1 {
            set runmode to 3.
        }
    }
    //Entry Burn
    else if runmode = 3 {
        if lngerrordiff(LZ) < 100 {
            set runmode to 4.
        }
    }
    //Gruding
    else if runmode = 4 {
        if rcs and ship:altitude < 20000 {
            rcs off.
        }

        if landth(7714.284, 3.8, 0) > 1 {
            set runmode to 5.
        }
    }
    //Landing Burn
    else if runmode = 5 {
        //Final Approach
        if landth(3857.142, 3.8, 0) < 1 {
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
            print truealt().

            set runmode to 0.
        }
    }
}

function thrott {
    if runmode = 1 or runmode = 2 or runmode = 4 {
        return 0.
    }
    else if runmode = 3 {
        return 1.
    }
    else if runmode = 5 {
        return landth(3857.142, 3.8, 0).
    }
}

function steer {
    if runmode = 1 {
        return mecosteer.
    }
    else if runmode = 2 or runmode = 3 {
        if ship:verticalSpeed < 0 and ship:altitude < 70000 {
            return steerpid(-15, 1.5, ship:velocity:surface, errorvector(LZ)).
        }
        else {
            return lookDirUp(ship:up:vector, facing:topvector).
        }
    }
    else if runmode = 4 {
        return steerpid(line(2000, 1, 30000, 15, truealt(), true, 1), 1.5, ship:velocity:surface, errorvector(refpoint(0.15, LZ))).
    }
    else if runmode = 5 {
        if truealt() > 100 {
            return steerpid(-1, 1, ship:velocity:surface, errorvector(refpoint(0.1, LZ))).
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

    brakes on.
}