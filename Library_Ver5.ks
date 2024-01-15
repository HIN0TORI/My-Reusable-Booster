//Library Ver3
//Script Ver1

//Celestia v2.2, Celestia v2.3

//-------------------------------------------------------------------

//List

//LZ
set LZlist to list().
LZlist:add(list()). //Ground Pad
LZlist:add(list()). //ASDS
//Ground Pad
LZlist[0]:add(latlng(-0.141231, -74.686727)). //LZ1
LZlist[0]:add(latlng(-0.161191, -74.686885)). //LZ2
LZlist[0]:add(latlng(-0.151208, -74.692589)). //LZ3
LZlist[0]:add(latlng(-0.156078, -74.605781)). //LZ4
LZlist[0]:add(latlng(-0.197051, -74.561683)). //LZ5
LZlist[0]:add(latlng(-0.197262, -74.538421)). //LZ6
//ASDS
LZlist[1]:add(latlng(-0.156077, -25.007526)). //ASDS1

//-------------------------------------------------------------------

//Function

function curve {
}

function line {
    parameter x1, y1, x2, y2, variable, AllowMin, minValue to 0.

    local ansA to 0.
    local ansB to 0.

    if x1 = 0 {
        set ansB to y1.
        set ansA to (y2 - ansB) / x2.
    }
    else {
        local mul to - (x2 / x1).
        local result_y to y1 * mul + y2.
        local result_b to mul + 1.

        set ansB to result_y / result_b.
        set ansA to (y1 - ansB) / x1.
    }

    if AllowMin {
        return variable * ansA + ansB.
    }
    else {
        local value to variable * ansA + ansB.

        if value > minValue {
            return value.
        }
        else {
            return minValue.
        }
    }
}

function truealt {
    local shipradar to alt:radar.

    if exalt > shipradar{
        return 0.
    }
    else {
        return shipradar - exalt.
    }
}

function fuelamount {
    parameter tag, res.

    local fuelRemain to 0.

    for tank in ship:partstagged(tag) {
        for fuel in tank:resources {
            if fuel:name = res {
                set fuelRemain to fuelRemain + fuel:amount.
            }
        }
    }

    return fuelRemain.
}

function acc {
    parameter power.

    return ((power) / ship:mass).
}

function pitchangle {
    return 90 - arctan2(vdot(vcrs(ship:up:vector, ship:north:vector), facing:forevector), vdot(ship:up:vector, facing:forevector)).
}

function impactpoint {
    if addons:tr:hasimpact {
        return addons:tr:impactpos.
    }
    else {
        return ship:geoPosition.
    }
}

function refpoint {
    parameter mag, tgt.

    return latlng((tgt:lat + (tgt:lat - ship:geoPosition:lat) * mag), (tgt:lng + (tgt:lng - ship:geoPosition:lng) * mag)).
}

function laterror {
    parameter tgt.

    return impactpoint():lat - tgt:lat.
}

function lngerror {
    parameter tgt.

    return impactpoint():lng - tgt:lng.
}

function lngerrordiff {
    parameter tgt.

    return abs(errorvector(tgt):z).
}

function errorvector {
    parameter tgt.

    return impactpoint():position - tgt:position.
}

function errordiff {
    parameter tgt.
    
    return sqrt((errorvector(tgt):x) ^ 2 + (errorvector(tgt):z) ^ 2).
}

function shiperrordiff {
    parameter tgt.

    local shiperrorvector to ship:geoposition:position - tgt:position.
    return sqrt((shiperrorvector:x) ^ 2 + (shiperrorvector:z) ^ 2).
}

function gravityturn {
    return heading(90, 90 - (ship:apoapsis / 1000)).
}

set boostbackyaw to pidloop(3, 2, 5, -5, 5).
set boostbackyaw:setpoint to 0.
function boostbackpid {
    parameter tgt.
    
    return r(boostbackyaw:update(time:seconds, laterror(tgt)), 0, 0).
}

function steerpid {
    parameter aoa, mag, vel, pos.

    local velvector to - vel.
    local result to (velvector + pos) * mag.
    if vang(result, velvector) > aoa {
        set result to velvector:normalized + tan(aoa) * pos:normalized.
    }
    return lookdirup(result, facing:topvector).
}

function landth {
    parameter power, tgalt, tgspeed.

    local landacc to (power / ship:mass) - (constant:g * body:mass / body:radius ^ 2).
    local stopdist to (ship:verticalspeed ^ 2 - tgspeed ^ 2) / (2 * landacc).
    return (stopdist + tgalt) / truealt().
}

function createnode {
    local gm to constant:g * kerbin:mass.
    local rap to ship:apoapsis + 600000.
    local vap to sqrt(gm * ((2 / rap) - (1 / ship:orbit:semimajoraxis))).
    local tgv to sqrt(gm * ((2 / rap) - (1 / rap))).
    local burnV to tgv - vap.

    set tgnode to node(timespan(eta:apoapsis), 0, 0, burnV).
    add tgnode.

    set burntime to (tgnode:deltav:mag / acc(ship:maxthrust)) / 2.
}

function fairing {
    for decoupler in ship:partstagged("fairing") {
        decoupler:getmodule("proceduralfairingdecoupler"):doevent("jettison fairing").
    }
    set fairingjet to true.
}

function enginemode {
    parameter mode.

    if defined eng = false or eng <> mode {
        set eng to mode.

        set center to ship:partstagged("center").
        set outer to ship:partstagged("outer").

        if mode = "Center" {
            for e in center {engineactivate(e).}
            for e in outer {engineshutdown(e).}
        }
        else if mode = "Full" {
            for e in center {engineactivate(e).}
            for e in outer {engineactivate(e).}
        }
        else if mode = "AllShutdown" {
            for e in center {engineshutdown(e).}
            for e in outer {engineshutdown(e).}
        }
    }

    function engineactivate {
        parameter e.

        local engine to e:getmodule("ModuleEnginesFX").
        if engine:hasevent("Activate Engine") {
            engine:doevent("Activate Engine").
        }
    }

    function engineshutdown {
        parameter e.

        local engine is e:getmodule("ModuleEnginesFX").
        if engine:hasevent("Shutdown Engine") {
            engine:doevent("Shutdown Engine").
        }
    }
}